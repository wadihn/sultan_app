import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/booking_model.dart';
import 'package:sultan_app/models/cafe_info_model.dart';
import 'package:sultan_app/models/category_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/offer_model.dart';
import 'package:sultan_app/models/order_item_model.dart';
import 'package:sultan_app/models/order_model.dart';
import 'package:sultan_app/models/opening_hour_model.dart';
import 'package:sultan_app/models/product_model.dart';
import 'package:sultan_app/models/product_option_group_model.dart';
import 'package:sultan_app/models/product_option_model.dart';

abstract final class DummyData {
  static const sizeOptions = ProductOptionGroupModel(
    id: 1,
    name: 'الحجم',
    isRequired: true,
    options: [
      ProductOptionModel(id: 1, name: 'صغير', price: 0),
      ProductOptionModel(id: 2, name: 'وسط', price: 0.50),
      ProductOptionModel(id: 3, name: 'كبير', price: 1),
    ],
  );

  static const extras = ProductOptionGroupModel(
    id: 2,
    name: 'الإضافات',
    allowsMultiple: true,
    options: [
      ProductOptionModel(id: 4, name: 'كراميل', price: 0.30),
      ProductOptionModel(id: 5, name: 'كريمة', price: 0.25),
      ProductOptionModel(id: 6, name: 'شوت إضافي', price: 0.50),
    ],
  );

  static const milkOptions = ProductOptionGroupModel(
    id: 3,
    name: 'نوع الحليب',
    isRequired: true,
    options: [
      ProductOptionModel(id: 7, name: 'عادي', price: 0),
      ProductOptionModel(id: 8, name: 'خالي اللاكتوز', price: 0.50),
    ],
  );

  static const categories = [
    CategoryModel(id: 1, name: 'قهوة'),
    CategoryModel(id: 2, name: 'مشروبات باردة'),
    CategoryModel(id: 3, name: 'أراجيل'),
    CategoryModel(id: 4, name: 'حلويات'),
    CategoryModel(id: 5, name: 'وجبات'),
  ];

  static const products = [
    ProductModel(
      id: 1,
      categoryId: 1,
      name: 'كابتشينو',
      description: 'إسبريسو مع حليب ورغوة ناعمة',
      price: 2.50,
      optionGroups: [sizeOptions, milkOptions, extras],
    ),
    ProductModel(
      id: 2,
      categoryId: 1,
      name: 'قهوة تركية',
      description: 'قهوة تركية محضرة على الطريقة التقليدية',
      price: 1.75,
    ),
    ProductModel(
      id: 3,
      categoryId: 2,
      name: 'آيس لاتيه',
      description: 'إسبريسو بارد مع الحليب والثلج',
      price: 3,
      optionGroups: [sizeOptions, milkOptions, extras],
    ),
    ProductModel(
      id: 4,
      categoryId: 4,
      name: 'تشيز كيك',
      description: 'قطعة تشيز كيك كريمية',
      price: 2.75,
    ),
    ProductModel(
      id: 5,
      categoryId: 3,
      name: 'أرجيلة تفاحتين',
      description: 'نكهة تفاحتين كلاسيكية بفحم طبيعي',
      price: 5,
      isAvailable: false,
    ),
    ProductModel(
      id: 6,
      categoryId: 5,
      name: 'ساندويش حلوم',
      description: 'خبز طازج مع جبنة الحلوم والخضار',
      price: 3.50,
    ),
  ];

  static const favoriteProductIds = <int>{1, 5};

  static const offers = [
    OfferModel(
      id: 1,
      title: 'خصم 20% على المشروبات الباردة',
      description: 'استمتع بمشروبك البارد المفضل طوال هذا الأسبوع',
    ),
  ];

  static final orders = [
    OrderModel(
      id: 1001,
      status: 'accepted',
      total: 5.50,
      createdAt: DateTime(2026, 8, 15, 18, 30),
      subtotal: 5.50,
      deliveryFee: 0,
      serviceType: 'booking',
      paymentMethod: 'pay_at_cafe',
      booking: BookingModel(
        id: 500,
        date: '2026-08-15',
        time: '20:35',
        peopleCount: 3,
        status: 'accepted',
        notes: 'طاولة قرب النافذة',
      ),
      items: const [
        OrderItemModel(
          productId: 1,
          productName: 'كابتشينو',
          quantity: 1,
          unitPrice: 2.50,
        ),
        OrderItemModel(
          productId: 4,
          productName: 'تشيز كيك',
          quantity: 1,
          unitPrice: 3,
        ),
      ],
    ),
    OrderModel(
      id: 1002,
      status: 'pending',
      createdAt: DateTime(2026, 8, 18, 14, 20),
      subtotal: 7,
      deliveryFee: 1.5,
      total: 8.5,
      serviceType: 'delivery',
      paymentMethod: 'cash_on_delivery',
      address: addresses.first,
      deliveryZone: deliveryZones[1],
      notes: 'يرجى الاتصال عند الوصول',
      items: const [
        OrderItemModel(
          productId: 1,
          productName: 'كابتشينو',
          quantity: 2,
          unitPrice: 3.5,
          selectedOptions: ['كبير', 'عادي'],
          notes: 'بدون سكر',
        ),
      ],
    ),
    OrderModel(
      id: 1003,
      status: 'ready',
      createdAt: DateTime(2026, 8, 16, 19, 10),
      subtotal: 3.5,
      deliveryFee: 0,
      total: 3.5,
      serviceType: 'booking',
      paymentMethod: 'pay_at_cafe',
      booking: BookingModel(
        id: 502,
        date: '2026-08-16',
        time: '20:15',
        peopleCount: 2,
        status: 'ready',
        notes: 'جلسة هادئة',
      ),
      items: const [
        OrderItemModel(
          productId: 2,
          productName: 'قهوة تركية',
          quantity: 2,
          unitPrice: 1.75,
        ),
      ],
    ),
    OrderModel(
      id: 1004,
      status: 'cancelled',
      createdAt: DateTime(2026, 8, 17, 16, 45),
      subtotal: 3.5,
      deliveryFee: 1,
      total: 4.5,
      serviceType: 'delivery',
      paymentMethod: 'cash_on_delivery',
      address: addresses.last,
      deliveryZone: deliveryZones.first,
      items: const [
        OrderItemModel(
          productId: 6,
          productName: 'ساندويش حلوم',
          quantity: 1,
          unitPrice: 3.5,
          notes: 'تغليف منفصل',
        ),
      ],
    ),
  ];

  static const addresses = [
    AddressModel(
      id: 1,
      title: 'المنزل',
      addressLine: 'عمّان، الجبيهة',
      phone: '0790000000',
      isDefault: true,
      landmark: 'بجانب المسجد',
      deliveryNotes: 'الطابق الثالث',
      deliveryZoneId: 2,
      deliveryZoneName: 'الكرك',
    ),
    AddressModel(
      id: 2,
      title: 'العمل',
      addressLine: 'الكرك، شارع الجامعة',
      phone: '0790000000',
      deliveryZoneId: 1,
      deliveryZoneName: 'مؤتة',
    ),
  ];

  static const deliveryZones = [
    DeliveryZoneModel(id: 1, name: 'مؤتة', deliveryFee: 1),
    DeliveryZoneModel(id: 2, name: 'الكرك', deliveryFee: 1.50),
    DeliveryZoneModel(id: 3, name: 'المرج', deliveryFee: 2),
  ];

  static const cafeInfo = CafeInfoModel(
    name: 'كافيه السلطان',
    phone: '0790000000',
    address: 'عمّان، الأردن',
    openingHours: [
      OpeningHourModel(
        dayOfWeek: 'sunday',
        openingTime: '10:00',
        closingTime: '01:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'monday',
        openingTime: '10:00',
        closingTime: '01:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'tuesday',
        openingTime: '10:00',
        closingTime: '01:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'wednesday',
        openingTime: '10:00',
        closingTime: '01:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'thursday',
        openingTime: '10:00',
        closingTime: '01:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'friday',
        openingTime: '14:00',
        closingTime: '02:00',
        isClosed: false,
      ),
      OpeningHourModel(
        dayOfWeek: 'saturday',
        openingTime: '10:00',
        closingTime: '02:00',
        isClosed: false,
      ),
    ],
    isOpen: true,
    statusMessage: 'ساعات العمل حسب جدول اليوم',
  );
}
