﻿using Cosmetics.Models;

namespace Cosmetics.Interfaces
{
    public interface IOrderRepository : IGenericRepository<Order>
    {
        Task<IEnumerable<Order>> GetOrdersByCustomerIdAsync(int customerId);
        Task<Order?> GetByIdAsync(Guid id, string includeProperties);
        Task<IEnumerable<Order>> GetConfirmedPaidOrdersForShipperAsync(int page, int pageSize);
        Task<Order?> GetInformationById(Guid id);
        
    }

}