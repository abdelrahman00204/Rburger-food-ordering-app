import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/models/cart_item.dart';
import 'package:rburger/models/product.dart';
import 'package:rburger/screens/cart_screen.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImageUrl = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.gold300,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: hasImageUrl
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    width: 76,
                    height: 76,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/burger-hero.png',
                      fit: BoxFit.cover,
                      width: 76,
                      height: 76,
                    ),
                  )
                : Image.asset(
                    'assets/burger-hero.png',
                    fit: BoxFit.cover,
                    width: 76,
                    height: 76,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.maroon800,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      product.priceLabel,
                      style: GoogleFonts.lalezar(
                        color: AppColors.ink900,
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.ink600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.maroon800,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onPressed: () {
                CartController.instance.addItem(
                  CartItem(
                    id: product.id,
                    name: product.name,
                    description: product.description,
                    unitPrice: product.price.round(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}