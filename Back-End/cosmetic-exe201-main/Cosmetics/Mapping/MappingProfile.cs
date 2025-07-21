﻿using AutoMapper;
using Cosmetics.DTO.Affiliate;
using Cosmetics.DTO.Brand;
using Cosmetics.DTO.Cart;
using Cosmetics.DTO.Category;
using Cosmetics.DTO.Chatbot;
using Cosmetics.DTO.KOLVideos;
using Cosmetics.DTO.Order;
using Cosmetics.DTO.OrderDetail;
using Cosmetics.DTO.Payment;
using Cosmetics.DTO.Product;
using Cosmetics.DTO.User;
using Cosmetics.DTO.User.Admin;
using Cosmetics.Models;

namespace Cosmetics.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserDTO>().ReverseMap();
            CreateMap<User, UserAdminDTO>().ReverseMap();
            //Product
            CreateMap<Product, ProductDTO>().ReverseMap();  
            CreateMap<Product, ProductCreateDTO>().ReverseMap();
            CreateMap<Product, ProductUpdateDTO>().ReverseMap();
            //Category
            CreateMap<Category, CategoryDTO>().ReverseMap();
            CreateMap<Category, CategoryCreateDTO>().ReverseMap();
            CreateMap<Category, CategoryUpdateDTO>().ReverseMap();
            //Brand
            CreateMap<Brand, BrandDTO>().ReverseMap();
            CreateMap<Brand, BrandCreateDTO>().ReverseMap();
            CreateMap<Brand, BrandUpdateDTO>().ReverseMap();
            //Order
            CreateMap<Order, OrderCreateDTO>().ReverseMap();
            CreateMap<Order, OrderResponseDTO>().ReverseMap();
            CreateMap<Order, OrderUpdateDTO>().ReverseMap();
            //OrderDetail
            CreateMap<OrderDetail, OrderDetailCreateDTO>().ReverseMap();
            CreateMap<OrderDetail, OrderDetailDTO>().ReverseMap();
            CreateMap<OrderDetail, OrderDetailUpdateDTO>().ReverseMap();
            //Affiliate


            //Payment
            CreateMap<PaymentTransaction, PaymentTransactionDTO>().ReverseMap();
            CreateMap<PaymentTransaction, PaymentRequestDTO>().ReverseMap();
            CreateMap<PaymentTransaction, PaymentResponseDTO>().ReverseMap();


            // Affiliate
            CreateMap<AffiliateProfile, AffiliateProfileDto>().ReverseMap();
            CreateMap<AffiliateProductLink, AffiliateLinkDto>().ReverseMap();
            CreateMap<TransactionAffiliate, WithdrawalResponseDto>()
                .ForMember(dest => dest.TransactionId, opt => opt.MapFrom(src => src.TransactionAffiliatesId))
                .ReverseMap();
   
            //Cart
            CreateMap<CartDetail, CartDetailDTO>().ReverseMap();
            CreateMap<CartDetail, CartDetailInputDTO>().ReverseMap();

            CreateMap<Kolvideo, KOLVideoDTO>().ReverseMap();
            CreateMap<Kolvideo, KOLVideoCreateDTO>().ReverseMap();
            CreateMap<Kolvideo, KOLVideoUpdateDTO>().ReverseMap();


            CreateMap<TransactionAffiliate, TransactionAffiliateDTO>()
            .ForMember(dest => dest.AffiliateProfileId, opt => opt.MapFrom(src => src.AffiliateProfileId ?? Guid.Empty));


            CreateMap<AffiliateProductLink, AffiliateLinkDto>()
    .ForMember(dest => dest.LinkId, opt => opt.MapFrom(src => src.LinkId))
    .ForMember(dest => dest.ProductId, opt => opt.MapFrom(src => src.ProductId));

            CreateMap<TransactionAffiliate, TransactionAffiliateExtendedDTO>()
                .ForMember(dest => dest.AffiliateProfileId, opt => opt.MapFrom(src => src.AffiliateProfileId ?? Guid.Empty))
                .ForMember(dest => dest.FirstName, opt => opt.MapFrom(src => src.AffiliateProfile != null && src.AffiliateProfile.User != null ? src.AffiliateProfile.User.FirstName : "N/A"))
                .ForMember(dest => dest.LastName, opt => opt.MapFrom(src => src.AffiliateProfile != null && src.AffiliateProfile.User != null ? src.AffiliateProfile.User.LastName : "N/A"))
                .ForMember(dest => dest.AffiliateName, opt => opt.MapFrom(src => src.AffiliateProfile != null && src.AffiliateProfile.User != null ? $"{src.AffiliateProfile.User.FirstName} {src.AffiliateProfile.User.LastName}" : "N/A"))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.AffiliateProfile != null && src.AffiliateProfile.User != null ? src.AffiliateProfile.User.Email : "N/A"))
                .ForMember(dest => dest.BankName, opt => opt.MapFrom(src => src.AffiliateProfile != null ? src.AffiliateProfile.BankName : "N/A"))
                .ForMember(dest => dest.BankAccountNumber, opt => opt.MapFrom(src => src.AffiliateProfile != null ? src.AffiliateProfile.BankAccountNumber : "N/A"))
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.TransactionDetail != null ? src.TransactionDetail.Image : null));

            // Chat History mappings
            CreateMap<ChatSession, ChatSessionDto>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.SpecifyKind(src.CreatedAt, DateTimeKind.Utc)))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.SpecifyKind(src.UpdatedAt, DateTimeKind.Utc)))
                .ReverseMap();
                
            CreateMap<ChatMessage, ChatMessageDto>()
                .ForMember(dest => dest.SentAt, opt => opt.MapFrom(src => DateTime.SpecifyKind(src.SentAt, DateTimeKind.Utc)))
                .ReverseMap();
        }
    }
}
