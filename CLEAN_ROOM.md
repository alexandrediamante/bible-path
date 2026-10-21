# Clean-room reconstruction notes

## Purpose

This repository implements a personal Bible companion from independently written Flutter and TypeScript code. Static analysis of a locally supplied Android APK may be used to describe observable product behavior, but not as a source of implementation or content.

## Allowed reference use

- Identify user-visible screens, navigation order, and interaction outcomes.
- Confirm broad feature categories.
- Record target package/version identity and bounded evidence used for a behavior claim.
- Reimplement behavior with original code and independently sourced, redistributable content.

## Excluded material

The repository must not contain material copied from the APK or its services, including:

- decompiled source or translated pseudocode;
- proprietary UI copy, devotionals, translations, artwork, icons, audio, or fonts;
- private endpoints, credentials, tokens, signing material, or configuration;
- license verification, billing, paywall, entitlement, or purchase-bypass logic;
- proprietary datasets or Firebase/RevenueCat data.

## Product claims

Features are documented as available only when they are implemented and verified. A local sample, placeholder, disabled handler, or in-memory demonstration is not described as a completed feature.

## Content provenance

Every third-party Bible text, font, icon, and other redistributed asset must have an entry in `THIRD_PARTY_CONTENT.md` with:

- exact work/edition;
- source URL and acquisition date;
- license or public-domain basis;
- attribution and modification notices;
- source and normalized SHA-256 when transformed.

Unknown provenance blocks public deployment.

## Known reference artifact

The local analysis workspace identifies the reference APK as Bible Path Android 2.5.6, package `com.visionwizard.holybible`, SHA-256 `25b43d80be8a270c17b22be1b1f1406c77e8551914ac284e5dd3096944b019da`.

This identity records the bounded reference artifact; it does not grant redistribution rights or permission to reuse its implementation or assets.
