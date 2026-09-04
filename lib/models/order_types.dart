enum ServiceType { booking, delivery }

enum PaymentMethod {
  payAtCafe('pay_at_cafe'),
  cashOnDelivery('cash_on_delivery');

  const PaymentMethod(this.code);
  final String code;
}
