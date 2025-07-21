using Cosmetics.DTO.OrderDetail;
using Cosmetics.Enum;

namespace Cosmetics.DTO.Order
{
    public class OrderCreateDTO
    {
        public int? SalesStaffId { get; set; }
        public DateTime? OrderDate { get; set; }
        public string PaymentMethod { get; set; }

        public string Address { get; set; }
        public List<OrderDetailCreateDTO> OrderDetails { get; set; }
        
        // Optional total amount (includes shipping, tax, etc.)
        public decimal? TotalAmount { get; set; }
        public decimal? ShippingFee { get; set; }
        public decimal? Tax { get; set; }
    }

}