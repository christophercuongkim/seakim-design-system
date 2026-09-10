factory SkColors.dark(SkBrandRamp brand) => SkColors(textAccent: brand.s300);
factory SkColors.light(SkBrandRamp brand) => SkColors(
        textAccent: brand.s600, // drifted: CSS says 700
      );
