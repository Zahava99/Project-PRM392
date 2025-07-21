using AutoMapper;
using Cosmetics.DTO.Payment;
using Cosmetics.Enum;
using Cosmetics.Models;
using Cosmetics.Repositories.UnitOfWork;
using Cosmetics.Service.Payment;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Net.payOS;

namespace Cosmetics.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class PaymentController : ControllerBase
	{
		private readonly IPaymentService _paymentService;
		private readonly IUnitOfWork _unitOfWork;
		private readonly PayOS _payOS;
		private readonly IMapper _mapper;
		private readonly ComedicShopDBContext _context;

		public PaymentController(
			IPaymentService paymentService,
			IUnitOfWork unitOfWork,
			PayOS payOS,
			IMapper mapper,
			ComedicShopDBContext context)
		{
			_paymentService = paymentService ?? throw new ArgumentNullException(nameof(paymentService));
			_unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
			_payOS = payOS ?? throw new ArgumentNullException(nameof(payOS));
			_mapper = mapper;
			_context = context ?? throw new ArgumentNullException(nameof(context));
		}

		[HttpPost("create-payment-link")]
		public async Task<IActionResult> CreatePayment([FromBody] PaymentRequestDTO request)
		{
			if (!ModelState.IsValid)
			{
				return BadRequest(ModelState);
			}

			try
			{
				// Check if payment already exists for this order
				var existingPayment = await _unitOfWork.PaymentTransactions.GetAsync(
					filter: p => p.OrderId == request.OrderId);
				
				if (existingPayment.Any())
				{
					var existing = existingPayment.First();
					// If payment is still pending, we can reuse it
					if (existing.Status == PaymentStatus.Pending)
					{
						// Get the existing payment link from PayOS
						// TODO: Fix PayOS checkoutUrl property name
						// try
						// {
						// 	var paymentInfo = await _payOS.getPaymentLinkInformation(long.Parse(existing.TransactionId));
						// 	if (paymentInfo != null && !string.IsNullOrEmpty(paymentInfo.checkoutUrl))
						// 	{
						// 		return Ok(new { PaymentUrl = paymentInfo.checkoutUrl });
						// 	}
						// }
						// catch (Exception ex)
						// {
						// 	// If getting existing payment fails, create new one
						// 	Console.WriteLine($"❌ Error getting existing payment info: {ex.Message}");
						// }
					}
					else
					{
						return BadRequest($"Payment already exists for this order with status: {existing.Status}");
					}
				}

				var paymentUrl = await _paymentService.CreatePaymentUrlAsync(request);
				return Ok(new { PaymentUrl = paymentUrl });
			}
			catch (Exception ex)
			{
				return StatusCode(500, $"An error occurred while creating the payment URL: {ex.Message}");
			}
		}

		[HttpGet("payments")]
		[Authorize]
		public async Task<IActionResult> GetAllPayments([FromQuery] int page = 1, [FromQuery] int pageSize = 10, [FromQuery] string? status = null)
		{
			try
			{
				var payments = await _unitOfWork.PaymentTransactions.GetAsync(
					filter: p => string.IsNullOrEmpty(status) || p.Status.ToString() == status,
					includeOperations: new Func<IQueryable<PaymentTransaction>, IQueryable<PaymentTransaction>>[]
					{
						q => q.Include(p => p.Order)
							.ThenInclude(o => o.Customer)
							.Include(p => p.Order)
							.ThenInclude(o => o.OrderDetails)
							.ThenInclude(od => od.Product)
					},
					orderBy: q => q.OrderByDescending(p => p.TransactionDate)
				);

				// Apply pagination manually
				var paginatedPayments = payments
					.Skip((page - 1) * pageSize)
					.Take(pageSize)
					.ToList();

				var totalCount = await _unitOfWork.PaymentTransactions.CountAsync(
					filter: p => string.IsNullOrEmpty(status) || p.Status.ToString() == status);

				var paymentDTOs = paginatedPayments.Select(p => new PaymentTransactionDTO
				{
					PaymentTransactionId = p.PaymentTransactionId,
					OrderId = p.OrderId,
					PaymentMethod = p.PaymentMethod,
					TransactionId = p.TransactionId,
					RequestId = p.RequestId,
					Amount = p.Amount,
					Status = p.Status,
					TransactionDate = p.TransactionDate,
					// Add order information
					OrderInfo = new
					{
						OrderId = p.Order.OrderId,
						CustomerName = $"{p.Order.Customer?.FirstName} {p.Order.Customer?.LastName}".Trim(),
						CustomerEmail = p.Order.Customer?.Email,
						TotalAmount = p.Order.TotalAmount,
						OrderDate = p.Order.OrderDate,
						Address = p.Order.Address,
						ProductCount = p.Order.OrderDetails?.Count ?? 0
					}
				}).ToList();

				var response = new
				{
					TotalCount = totalCount,
					TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize),
					CurrentPage = page,
					PageSize = pageSize,
					Payments = paymentDTOs
				};

				return Ok(response);
			}
			catch (Exception ex)
			{
				return StatusCode(500, $"An error occurred while retrieving payments: {ex.Message}");
			}
		}

		[HttpGet("payment/{transactionId}")]
		public async Task<IActionResult> GetPayment(string transactionId)
		{
			if (transactionId == string.Empty)
				return BadRequest("Transaction ID is required");

			try
			{
				var payment = await _paymentService.GetPaymentByTransactionIdAsync(transactionId);
				if (payment == null)
					return NotFound($"No payment found with Transaction ID: {transactionId}");

				return Ok(payment);
			}
			catch (Exception ex)
			{
				// Log the exception if you have a logging service
				return StatusCode(500, $"An error occurred while retrieving the payment: {ex.Message}");
			}
		}

		[HttpPut("update-payment-status/{transactionId}")]
		public async Task<IActionResult> UpdatePaymentStatus(string transactionId, [FromQuery] int newStatus)
		{
			if (string.IsNullOrEmpty(transactionId))
				return BadRequest("Transaction ID is required");

			// Kiểm tra status đầu vào
			if (!System.Enum.IsDefined(typeof(PaymentStatus), newStatus) ||
				(newStatus != (int)PaymentStatus.Success && newStatus != (int)PaymentStatus.Failed))
			{
				return BadRequest("New status must be either Success (1) or Fail (2)");
			}

			try
			{
				var payment = await _paymentService.GetPaymentByTransactionIdAsync(transactionId);
				if (payment == null)
					return NotFound($"No payment found with Transaction ID: {transactionId}");

				if (payment.Status != PaymentStatus.Pending)
					return BadRequest($"Payment status can only be updated from Pending (0) to Success (1) or Fail (2). Current status: {payment.Status}");

				var updatedPayment = new PaymentResponseDTO
				{
					TransactionId = payment.TransactionId,
					Amount = payment.Amount,
					ResultCode = payment.ResultCode,
					ResponseTime = DateTime.UtcNow,
					Status = (PaymentStatus)newStatus // Sử dụng status từ request
				};

				var success = await _paymentService.UpdatePaymentStatusAsync(updatedPayment);
				if (!success)
					return BadRequest($"Failed to update payment status. Either the status is invalid or the transaction cannot be updated.");
				var OrderId = payment.OrderId;
				if (OrderId != null)
				{
					var order = await _unitOfWork.Orders.GetByIdAsync(OrderId);

					if (order == null) return NotFound();
					if (order == null)
						return NotFound($"No order found for this payment with Transaction ID: {payment.TransactionId}");

					// Cập nhật trạng thái đơn hàng dựa vào trạng thái thanh toán
					if (updatedPayment.Status == PaymentStatus.Success)
					{
						order.Status = OrderStatus.Paid;
						
						// 🔥 UPDATE AFFILIATE COMMISSION WHEN PAYMENT SUCCESS
						await UpdateAffiliateCommissionStatusAsync(order.OrderId, true);
					}
					else
					{
						order.Status = OrderStatus.Cancelled;
					}

					await _unitOfWork.Orders.UpdateAsync(order);
					await _unitOfWork.CompleteAsync();
				}
				string statusMessage = updatedPayment.Status == PaymentStatus.Success
					? "Success (1)"
					: "Fail (2)";
				return Ok(new
				{
					Message = $"Payment status updated to {statusMessage} for Transaction ID: {transactionId}",
					UpdatedStatus = updatedPayment.Status,
					ResponseTime = updatedPayment.ResponseTime
				});
			}
			catch (Exception ex)
			{
				return StatusCode(500, $"An error occurred while updating the payment status: {ex.Message}");
			}
		}

		[HttpDelete("{id}")]
		[Authorize]
		public async Task<IActionResult> DeleteOrder(Guid id)
		{
			var order = await _unitOfWork.Orders.GetByIdAsync(id);
			if (order == null) return NotFound();

			_unitOfWork.Orders.Delete(order);
			await _unitOfWork.CompleteAsync();
			return NoContent();
		}

		[HttpGet("HandlePayment")]
		[HttpPost("HandlePayment")]
		public async Task<IActionResult> HandlePayment()
		{
			try
			{
				Console.WriteLine("🔔 HandlePayment endpoint called");
				Console.WriteLine($"🔍 Request Method: {Request.Method}");
				Console.WriteLine($"🔍 Query Parameters: {Request.QueryString}");
				
				// Log all query parameters for debugging
				foreach (var param in Request.Query)
				{
					Console.WriteLine($"📋 Query param: {param.Key} = {param.Value}");
				}

				// Extract common PayOS callback parameters
				var orderCode = Request.Query["orderCode"].FirstOrDefault();
				var resultCode = Request.Query["code"].FirstOrDefault();
				var cancel = Request.Query["cancel"].FirstOrDefault();
				var status = Request.Query["status"].FirstOrDefault();
				var id = Request.Query["id"].FirstOrDefault();

				Console.WriteLine($"🔍 Parsed parameters - OrderCode: {orderCode}, ResultCode: {resultCode}, Cancel: {cancel}, Status: {status}, ID: {id}");

				// Determine if this is a success or cancellation
				bool isSuccess = false;
				bool isCancellation = false;

				if (!string.IsNullOrEmpty(cancel) && cancel.ToLower() == "true")
				{
					isCancellation = true;
					Console.WriteLine("❌ Payment was cancelled by user");
				}
				else if (!string.IsNullOrEmpty(resultCode))
				{
					// PayOS success codes are typically "00" or "000"
					isSuccess = resultCode == "00" || resultCode == "000";
					Console.WriteLine($"✅ Payment result code: {resultCode}, Success: {isSuccess}");
				}
				else if (!string.IsNullOrEmpty(status))
				{
					isSuccess = status.ToLower() == "paid" || status.ToLower() == "success";
					Console.WriteLine($"💰 Payment status: {status}, Success: {isSuccess}");
				}

				// If we have order code, try to find the transaction and update status
				if (!string.IsNullOrEmpty(orderCode))
				{
					// Find payment transaction by order code
					var paymentTransactions = await _unitOfWork.PaymentTransactions.GetAsync(
						filter: pt => pt.TransactionId == orderCode
					);

					var paymentTransaction = paymentTransactions.FirstOrDefault();
					
					if (paymentTransaction != null)
					{
						Console.WriteLine($"📋 Found payment transaction: {paymentTransaction.PaymentTransactionId}");
						
						// Update payment status
						if (isCancellation)
						{
							paymentTransaction.Status = PaymentStatus.Failed;
							Console.WriteLine("❌ Setting payment status to Failed (cancelled)");
						}
						else if (isSuccess)
						{
							paymentTransaction.Status = PaymentStatus.Success;
							Console.WriteLine("✅ Setting payment status to Success");
						}
						else
						{
							// Default to failed if not explicitly successful
							paymentTransaction.Status = PaymentStatus.Failed;
							Console.WriteLine("⚠️ Setting payment status to Failed (default)");
						}

						paymentTransaction.ResponseTime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
						paymentTransaction.ResultCode = int.TryParse(resultCode, out var code) ? code : (int?)null;

						await _unitOfWork.PaymentTransactions.UpdateAsync(paymentTransaction);

						// Update order status
						var order = await _unitOfWork.Orders.GetByIdAsync(paymentTransaction.OrderId);
						if (order != null)
						{
							if (isSuccess)
							{
								order.Status = OrderStatus.Paid;
								Console.WriteLine("✅ Setting order status to Paid");
								
								// 🔥 UPDATE AFFILIATE COMMISSION WHEN PAYMENT SUCCESS
								await UpdateAffiliateCommissionStatusAsync(order.OrderId, true);
							}
							else
							{
								order.Status = OrderStatus.Cancelled;
								Console.WriteLine("❌ Setting order status to Cancelled");
							}

							await _unitOfWork.Orders.UpdateAsync(order);
						}

						await _unitOfWork.CompleteAsync();
						Console.WriteLine("💾 Database updates completed");

						// Return appropriate response
						if (isCancellation)
						{
							return Ok(new 
							{ 
								message = "Payment was cancelled", 
								status = "cancelled",
								orderCode = orderCode,
								timestamp = DateTime.UtcNow
							});
						}
						else if (isSuccess)
						{
							return Ok(new 
							{ 
								message = "Payment processed successfully", 
								status = "success",
								orderCode = orderCode,
								timestamp = DateTime.UtcNow
							});
						}
						else
						{
							return Ok(new 
							{ 
								message = "Payment failed", 
								status = "failed",
								orderCode = orderCode,
								timestamp = DateTime.UtcNow
							});
						}
					}
					else
					{
						Console.WriteLine($"❌ No payment transaction found for order code: {orderCode}");
						return NotFound(new 
						{ 
							message = "Payment transaction not found", 
							orderCode = orderCode,
							timestamp = DateTime.UtcNow
						});
					}
				}

				// If no order code provided, return generic response
				Console.WriteLine("⚠️ No order code provided in callback");
				return Ok(new 
				{ 
					message = "Payment callback received", 
					status = isCancellation ? "cancelled" : (isSuccess ? "success" : "unknown"),
					timestamp = DateTime.UtcNow
				});
			}
			catch (Exception ex)
			{
				Console.WriteLine($"❌ Error in HandlePayment: {ex.Message}");
				Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
				return StatusCode(500, new 
				{ 
					message = "Internal server error while processing payment callback", 
					error = ex.Message,
					timestamp = DateTime.UtcNow
				});
			}
		}

		[HttpGet("HandlePaymentSuccess")]
		[HttpPost("HandlePaymentSuccess")]
		public async Task<IActionResult> HandlePaymentSuccess()
		{
			try
			{
				Console.WriteLine("✅ HandlePaymentSuccess endpoint called");
				Console.WriteLine($"🔍 Request Method: {Request.Method}");
				Console.WriteLine($"🔍 Query Parameters: {Request.QueryString}");

				// Log all query parameters for debugging
				foreach (var param in Request.Query)
				{
					Console.WriteLine($"📋 Query param: {param.Key} = {param.Value}");
				}

				// Extract PayOS callback parameters
				var orderCode = Request.Query["orderCode"].FirstOrDefault();
				var resultCode = Request.Query["code"].FirstOrDefault();
				var status = Request.Query["status"].FirstOrDefault();
				var id = Request.Query["id"].FirstOrDefault();

				Console.WriteLine($"✅ Success callback - OrderCode: {orderCode}, ResultCode: {resultCode}, Status: {status}, ID: {id}");

				if (!string.IsNullOrEmpty(orderCode))
				{
					// Find payment transaction by order code
					var paymentTransactions = await _unitOfWork.PaymentTransactions.GetAsync(
						filter: pt => pt.TransactionId == orderCode
					);

					var paymentTransaction = paymentTransactions.FirstOrDefault();

					if (paymentTransaction != null)
					{
						Console.WriteLine($"📋 Found payment transaction: {paymentTransaction.PaymentTransactionId}");

						// Update payment status to Success
						paymentTransaction.Status = PaymentStatus.Success;
						paymentTransaction.ResponseTime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
						paymentTransaction.ResultCode = int.TryParse(resultCode, out var code) ? code : 0;

						await _unitOfWork.PaymentTransactions.UpdateAsync(paymentTransaction);

						// Update order status to Paid
						var order = await _unitOfWork.Orders.GetByIdAsync(paymentTransaction.OrderId);
						if (order != null)
						{
							order.Status = OrderStatus.Paid;
							Console.WriteLine("✅ Setting order status to Paid");
							await _unitOfWork.Orders.UpdateAsync(order);
							
							// 🔥 UPDATE AFFILIATE COMMISSION WHEN PAYMENT SUCCESS
							await UpdateAffiliateCommissionStatusAsync(order.OrderId, true);
						}

						await _unitOfWork.CompleteAsync();
						Console.WriteLine("💾 Success: Database updates completed");

						// Redirect to deep link with parameters
						var deepLinkUrl = $"cosmotopia://payment-success?orderCode={orderCode}&amount={paymentTransaction.Amount}&code={resultCode}&status=PAID";
						Console.WriteLine($"🔗 Redirecting to deep link: {deepLinkUrl}");
						
						return Redirect(deepLinkUrl);
					}
					else
					{
						Console.WriteLine($"❌ No payment transaction found for order code: {orderCode}");
						var errorDeepLink = $"cosmotopia://payment-cancel?orderCode={orderCode}&reason=Transaction not found";
						return Redirect(errorDeepLink);
					}
				}

				Console.WriteLine("⚠️ No order code provided in success callback");
				var genericErrorDeepLink = "cosmotopia://payment-cancel?reason=No order code provided";
				return Redirect(genericErrorDeepLink);
			}
			catch (Exception ex)
			{
				Console.WriteLine($"❌ Error in HandlePaymentSuccess: {ex.Message}");
				Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
				var errorDeepLink = $"cosmotopia://payment-cancel?reason=Server error: {Uri.EscapeDataString(ex.Message)}";
				return Redirect(errorDeepLink);
			}
		}

		[HttpGet("HandlePaymentCancel")]
		[HttpPost("HandlePaymentCancel")]
		public async Task<IActionResult> HandlePaymentCancel()
		{
			try
			{
				Console.WriteLine("❌ HandlePaymentCancel endpoint called");
				Console.WriteLine($"🔍 Request Method: {Request.Method}");
				Console.WriteLine($"🔍 Query Parameters: {Request.QueryString}");

				// Log all query parameters for debugging
				foreach (var param in Request.Query)
				{
					Console.WriteLine($"📋 Query param: {param.Key} = {param.Value}");
				}

				// Extract PayOS callback parameters
				var orderCode = Request.Query["orderCode"].FirstOrDefault();
				var cancel = Request.Query["cancel"].FirstOrDefault();
				var id = Request.Query["id"].FirstOrDefault();

				Console.WriteLine($"❌ Cancel callback - OrderCode: {orderCode}, Cancel: {cancel}, ID: {id}");

				if (!string.IsNullOrEmpty(orderCode))
				{
					// Find payment transaction by order code
					var paymentTransactions = await _unitOfWork.PaymentTransactions.GetAsync(
						filter: pt => pt.TransactionId == orderCode
					);

					var paymentTransaction = paymentTransactions.FirstOrDefault();

					if (paymentTransaction != null)
					{
						Console.WriteLine($"📋 Found payment transaction: {paymentTransaction.PaymentTransactionId}");

						// Update payment status to Canceled
						paymentTransaction.Status = PaymentStatus.Canceled;
						paymentTransaction.ResponseTime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");

						await _unitOfWork.PaymentTransactions.UpdateAsync(paymentTransaction);

						// Update order status to Cancelled
						var order = await _unitOfWork.Orders.GetByIdAsync(paymentTransaction.OrderId);
						if (order != null)
						{
							order.Status = OrderStatus.Cancelled;
							Console.WriteLine("❌ Setting order status to Cancelled");
							await _unitOfWork.Orders.UpdateAsync(order);
						}

						await _unitOfWork.CompleteAsync();
						Console.WriteLine("💾 Cancel: Database updates completed");

						// Redirect to deep link with parameters
						var deepLinkUrl = $"cosmotopia://payment-cancel?orderCode={orderCode}&reason=User cancelled payment";
						Console.WriteLine($"🔗 Redirecting to deep link: {deepLinkUrl}");
						
						return Redirect(deepLinkUrl);
					}
					else
					{
						Console.WriteLine($"❌ No payment transaction found for order code: {orderCode}");
						var errorDeepLink = $"cosmotopia://payment-cancel?orderCode={orderCode}&reason=Transaction not found";
						return Redirect(errorDeepLink);
					}
				}

				Console.WriteLine("⚠️ No order code provided in cancel callback");
				var genericErrorDeepLink = "cosmotopia://payment-cancel?reason=No order code provided";
				return Redirect(genericErrorDeepLink);
			}
			catch (Exception ex)
			{
				Console.WriteLine($"❌ Error in HandlePaymentCancel: {ex.Message}");
				Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
				var errorDeepLink = $"cosmotopia://payment-cancel?reason=Server error: {Uri.EscapeDataString(ex.Message)}";
				return Redirect(errorDeepLink);
			}
		}

		/// <summary>
		/// Helper method to update AffiliateCommission.IsPaid status when payment succeeds
		/// </summary>
		private async Task UpdateAffiliateCommissionStatusAsync(Guid orderId, bool isPaid)
		{
			try
			{
				Console.WriteLine($"🔄 Updating affiliate commission status for OrderId: {orderId}, IsPaid: {isPaid}");

				// Get order details with affiliate profiles
				var orderDetails = await _context.OrderDetails
					.Where(od => od.OrderId == orderId && od.AffiliateProfileId.HasValue)
					.ToListAsync();

				if (orderDetails.Any())
				{
					var orderDetailIds = orderDetails.Select(od => od.OrderDetailId).ToList();

					// Get affiliate commissions for these order details
					var affiliateCommissions = await _context.AffiliateCommissions
						.Where(ac => orderDetailIds.Contains(ac.OrderDetailId))
						.ToListAsync();

					if (affiliateCommissions.Any())
					{
						foreach (var commission in affiliateCommissions)
						{
							commission.IsPaid = isPaid;
							Console.WriteLine($"✅ Setting AffiliateCommission.IsPaid = {isPaid} for CommissionId: {commission.CommissionId}, AffiliateProfileId: {commission.AffiliateProfileId}, Amount: {commission.CommissionAmount}");
						}

						// Update commissions
						_context.AffiliateCommissions.UpdateRange(affiliateCommissions);
						await _context.SaveChangesAsync();

						Console.WriteLine($"💾 Updated {affiliateCommissions.Count} affiliate commissions successfully");
					}
					else
					{
						Console.WriteLine("⚠️ No affiliate commissions found for this order");
					}
				}
				else
				{
					Console.WriteLine("⚠️ No order details with affiliate profiles found");
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine($"❌ Error updating affiliate commission status: {ex.Message}");
				Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
				// Don't rethrow - payment should still succeed even if commission update fails
			}
		}
	}
}