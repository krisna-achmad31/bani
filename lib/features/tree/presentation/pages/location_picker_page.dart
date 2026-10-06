import 'package:bani/l10n/l10n.dart';
import 'dart:async';

import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  07 Pilih lokasi — OpenStreetMap + fixed centre pin + reverse geocoding.
//  Returns a GeoPlace via context.pop(place).
// ─────────────────────────────────────────────────────────────────────────────

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, required this.args});
  final LocationPickerArgs args;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _kediri = LatLng(-7.8166, 112.0114);
  static const _locale = Locale('id', 'ID');

  final _map = MapController();
  final _search = TextEditingController();
  final _detail = TextEditingController();
  final _geocoding = Geocoding();

  /// Coordinates under the pin tip (not the map's geometric centre: the pin
  /// sits in the middle of the area left visible above the bottom panel).
  late LatLng _center;
  String? _address;
  final _sheetKey = GlobalKey();
  var _sheetHeight = 330.0;
  var _size = Size.zero;

  Offset get _pinTip =>
      Offset(_size.width / 2, ((_size.height - _sheetHeight) / 2 + 24).clamp(140.0, _size.height));

  /// [MapController.move] offset that places a point at the pin tip.
  Offset get _pinOffset => Offset(0, _pinTip.dy - _size.height / 2);

  void _moveTo(LatLng p, double zoom) {
    _map.move(p, zoom, offset: _pinOffset);
    _center = p;
  }

  void _measureSheet() {
    final h = _sheetKey.currentContext?.size?.height;
    if (h != null && (h - _sheetHeight).abs() > 1) {
      setState(() => _sheetHeight = h);
      _moveTo(_center, _map.camera.zoom);
    }
  }

  var _resolving = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final init = widget.args.initial;
    _center = init?.hasCoordinates == true ? LatLng(init!.lat!, init.lng!) : _kediri;
    _address = init?.text;
    _detail.text = init?.detail ?? '';
    if (init == null) _resolve(_center);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _resolve(LatLng p) async {
    setState(() => _resolving = true);
    try {
      final marks = await _geocoding.placemarkFromCoordinates(
        p.latitude,
        p.longitude,
        locale: _locale,
      );
      final m = marks.firstOrNull;
      if (m != null && mounted) {
        setState(
          () => _address = [
            m.street,
            m.subLocality,
            m.locality,
            m.subAdministrativeArea,
          ].where((s) => s != null && s.trim().isNotEmpty).toSet().join(', '),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _address ??= context.t.mapSelected);
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _find(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final result = await _geocoding.locationFromAddress(query, locale: _locale);
      final loc = result.firstOrNull;
      if (loc == null) {
        if (mounted) showMessage(context, context.t.mapNotFound);
        return;
      }
      final p = LatLng(loc.latitude, loc.longitude);
      _moveTo(p, 16);
      await _resolve(p);
    } catch (_) {
      if (mounted) showMessage(context, context.t.mapNotFound);
    }
  }

  Future<void> _myLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) showMessage(context, context.t.mapPermissionDenied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      _moveTo(p, 17);
      await _resolve(p);
    } catch (e) {
      if (mounted) showMessage(context, context.t.mapNoGps);
    }
  }

  @override
  Widget build(BuildContext context) {
    const shadow = [BoxShadow(color: Color(0x1F1F2A24), blurRadius: 8, offset: Offset(0, 2))];
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _size = constraints.biggest;
          final tip = _pinTip;
          return Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: widget.args.initial?.hasCoordinates == true ? 17 : 13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () {
                      _moveTo(_center, _map.camera.zoom);
                      WidgetsBinding.instance.addPostFrameCallback((_) => _measureSheet());
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (!hasGesture) return;
                      _center = camera.screenOffsetToLatLng(tip);
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 600), () => _resolve(_center));
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.osmTileUrl,
                      userAgentPackageName: AppConstants.userAgentPackage,
                    ),
                    const SimpleAttributionWidget(source: Text('OpenStreetMap')),
                  ],
                ),
              ),
              // Fixed pin; its tip (bottom of the stick) is exactly at [tip].
              Positioned(
                left: tip.dx - 24,
                top: tip.dy - 62,
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x668A4B2A),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                      ),
                      Container(width: 3, height: 14, color: AppColors.primary),
                      Transform.translate(
                        offset: const Offset(0, -3),
                        child: Container(
                          width: 16,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0x331F2A24),
                            borderRadius: BorderRadius.all(Radius.elliptical(8, 3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: shadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: shadow,
                          ),
                          child: TextField(
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _find,
                            decoration: InputDecoration(
                              hintText: context.t.mapSearch,
                              prefixIcon: const Icon(Icons.search, color: AppColors.ink3),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: shadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                          tooltip: context.t.mapMyLocation,
                          onPressed: _myLocation,
                        ),
                      ),
                    ),
                    Container(
                      key: _sheetKey,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A1F2A24),
                            blurRadius: 20,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args.title.toUpperCase(),
                              style: AppText.body(
                                11,
                                weight: FontWeight.w700,
                                color: AppColors.gold,
                              ).copyWith(letterSpacing: 1),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.place_outlined, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _resolving
                                            ? context.t.mapResolving
                                            : (_address ?? context.t.mapDrag),
                                        style: AppText.body(16, weight: FontWeight.w700),
                                      ),
                                      Text(
                                        '${_center.latitude.toStringAsFixed(5)}, '
                                        '${_center.longitude.toStringAsFixed(5)}',
                                        style: AppText.body(13, color: AppColors.ink2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _detail,
                              decoration: InputDecoration(
                                hintText: context.t.mapDetailHint,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: _resolving
                                  ? null
                                  : () => Navigator.pop(
                                      context,
                                      GeoPlace(
                                        text: _address ?? context.t.mapSelected,
                                        detail: _detail.text.trim().isEmpty
                                            ? null
                                            : _detail.text.trim(),
                                        lat: _center.latitude,
                                        lng: _center.longitude,
                                      ),
                                    ),
                              icon: const Icon(Icons.check),
                              label: Text(context.t.mapUse),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
