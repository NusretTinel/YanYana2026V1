import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/services/geocoding_service.dart';
import 'package:yanyana_p/core/services/location_service.dart';
import 'package:yanyana_p/core/services/place_service.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/core/utils/feature_dialogs.dart';
import 'package:yanyana_p/features/map/widgets/place_details_sheet.dart';
import 'package:yanyana_p/features/map/widgets/place_form_dialog.dart';
import 'package:yanyana_p/features/map/widgets/emergency_map_marker.dart';
import 'package:yanyana_p/features/map/widgets/emergency_request_sheet.dart';
import 'package:yanyana_p/features/map/widgets/map_compact_fab.dart';
import 'package:yanyana_p/features/map/widgets/map_filter_sheet.dart';
import 'package:yanyana_p/features/map/widgets/place_list_panel.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final _mapController = MapController();
  final _placesSheetKey = GlobalKey<_SavedPlacesSheetState>();
  final _sheetExtent = ValueNotifier<double>(0.14);
  final _backend = BackendOrchestrator.instance;
  final _placeService = PlaceService.instance;
  final _locationService = const LocationService();
  final _geocodingService = const GeocodingService();
  final _searchCtrl = TextEditingController();

  StreamSubscription<List<AccessiblePlace>>? _placesSub;
  StreamSubscription<List<EmergencyRequest>>? _sosSub;

  List<AccessiblePlace> _allPlaces = [];
  List<EmergencyRequest> _emergencyRequests = [];
  bool _loading = true;
  bool _mapReady = false;
  String? _mapError;
  LatLng? _userLocation;

  String _searchQuery = '';
  String _categoryFilter = 'Tümü';
  final Set<String> _accessibilityFilters = {};
  PlaceListSort _listSort = PlaceListSort.name;
  String? _selectedPlaceId;
  bool _searchingLocation = false;

  static const _accessFilterOptions = <MapEntry<String, String>>[
    MapEntry('wheelchair', 'Tekerlekli sandalye'),
    MapEntry('restroom', 'Tuvalet'),
    MapEntry('elevator', 'Asansör'),
    MapEntry('ramp', 'Rampa'),
    MapEntry('hearing', 'İşitme'),
    MapEntry('visual', 'Görsel'),
  ];

  @override
  void initState() {
    super.initState();
    _subscribeStreams();
  }

  void _subscribeStreams({bool showLoadingOverlay = true}) {
    _placesSub?.cancel();
    _sosSub?.cancel();
    if (showLoadingOverlay && _allPlaces.isEmpty) {
      setState(() => _loading = true);
    }
    _placesSub = _backend.streamAccessiblePlaces().listen(
      (places) {
        if (!mounted) return;
        setState(() {
          _allPlaces = places;
          _loading = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _mapError = 'Mekanlar yüklenemedi: $e';
        });
      },
    );
    _sosSub = _backend.streamMapEmergencyRequests().listen(
      (requests) {
        if (!mounted) return;
        setState(() => _emergencyRequests = requests);
      },
    );
  }

  /// Call when the map tab becomes visible (e.g. after SOS from Home).
  void refreshEmergencyMarkers() {
    _sosSub?.cancel();
    _sosSub = _backend.streamMapEmergencyRequests().listen(
      (requests) {
        if (!mounted) return;
        setState(() => _emergencyRequests = requests);
      },
    );
  }

  @override
  void dispose() {
    _placesSub?.cancel();
    _sosSub?.cancel();
    _searchCtrl.dispose();
    _sheetExtent.dispose();
    super.dispose();
  }

  AccessiblePlace? _placeById(String id) {
    try {
      return _allPlaces.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _openSavedPlacesPanel() {
    _placesSheetKey.currentState?.expand();
  }

  void _selectPlace(AccessiblePlace place) {
    _focusPlaceOnMap(place);
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      final current = _placeById(place.id) ?? place;
      _openPlaceDetails(current);
    });
  }

  List<AccessiblePlace> get _filteredPlaces => _placeService.filterPlaces(
        places: _allPlaces,
        searchQuery: _searchQuery,
        categoryFilter: _categoryFilter,
        accessibilityFilters: _accessibilityFilters,
      );

  Future<void> _reloadPlaces() async {
    try {
      final places = await _placeService.getPlaces();
      if (!mounted) return;
      setState(() => _allPlaces = places);
    } catch (e) {
      if (!mounted) return;
      setState(() => _mapError = 'Mekanlar yüklenemedi: $e');
    }
  }

  LatLng _mapCenter() {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return LocationService.defaultCenter;
    }
  }

  Future<void> _showMyLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userLocation = pos);
      _mapController.move(pos, 15);
    } on LocationFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    }
  }

  Future<void> _openAddPlace() async {
    final center = _mapCenter();
    final result = await showPlaceFormDialog(
      context: context,
      latitude: center.latitude,
      longitude: center.longitude,
    );
    if (result == null || !mounted) return;
    try {
      final added = await _backend.addAccessiblePlace(
        name: result.name,
        category: result.category,
        latitude: result.latitude,
        longitude: result.longitude,
        description: result.description,
        rating: result.rating,
        wheelchairAccessible: result.wheelchairAccessible,
        hasAccessibleToilet: result.hasAccessibleToilet,
        hasElevator: result.hasElevator,
        hasRamp: result.hasRamp,
        hearingSupport: result.hearingSupport,
        visualSupport: result.visualSupport,
      );
      await _reloadPlaces();
      if (!mounted) return;
      final place = _placeById(added.id) ?? added;
      _selectPlace(place);
      _openSavedPlacesPanel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız: $e')),
      );
    }
  }

  Future<void> _openEditPlace(AccessiblePlace place) async {
    final result = await showPlaceFormDialog(
      context: context,
      latitude: place.latitude,
      longitude: place.longitude,
      existing: place,
    );
    if (result == null || !mounted) return;
    try {
      final updated = place.copyWith(
        name: result.name,
        category: result.category,
        description: result.description,
        rating: result.rating,
        wheelchairAccessible: result.wheelchairAccessible,
        hasAccessibleToilet: result.hasAccessibleToilet,
        hasElevator: result.hasElevator,
        hasRamp: result.hasRamp,
        hearingSupport: result.hearingSupport,
        visualSupport: result.visualSupport,
      );
      await _backend.updateAccessiblePlace(updated);
      await _reloadPlaces();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mekan güncellendi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme başarısız: $e')),
      );
    }
  }

  void _focusPlaceOnMap(AccessiblePlace place) {
    setState(() => _selectedPlaceId = place.id);
    _mapController.move(LatLng(place.latitude, place.longitude), 16);
  }

  Future<void> _searchLocation() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _searchingLocation = true);

    try {
      final results = await _geocodingService.searchLocations(query);
      if (!mounted) return;
      setState(() => _searchingLocation = false);

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$query" için konum bulunamadı.')),
        );
        return;
      }

      if (results.length == 1) {
        _goToGeocodingResult(results.first);
        return;
      }

      final picked = await showModalBottomSheet<GeocodingResult>(
        context: context,
        backgroundColor: YanYanaColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Konum seçin',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = results[index];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(
                          r.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: r.kind.isNotEmpty
                            ? Text(r.kind, style: const TextStyle(fontSize: 12))
                            : null,
                        onTap: () => Navigator.pop(ctx, r),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (picked != null && mounted) {
        _goToGeocodingResult(picked);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum aranamadı: $e')),
      );
    }
  }

  void _goToGeocodingResult(GeocodingResult result) {
    final zoom = result.kind.contains('suburb') ||
            result.kind.contains('neighbourhood') ||
            result.kind.contains('quarter')
        ? 14.0
        : result.kind.contains('city') || result.kind.contains('town')
            ? 12.0
            : 13.5;
    _mapController.move(result.latLng, zoom);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.displayName.split(',').first.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openPlaceDetails(AccessiblePlace place) async {
    final reviews = await _backend.fetchPlaceReviews(place.id);
    if (!mounted) return;
    showPlaceDetailsSheet(
      context: context,
      place: place,
      reviews: reviews,
      onEdit: () => _openEditPlace(place),
      onDelete: () async {
        await _backend.deleteAccessiblePlace(place.id);
        await _reloadPlaces();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mekan silindi.')),
          );
        }
      },
      onAddReview: (comment, rating) async {
        await _backend.addPlaceReview(
          placeId: place.id,
          comment: comment,
          rating: rating,
          placeSnapshot: place,
        );
        await _reloadPlaces();
      },
    );
  }

  Future<void> _triggerSos() async {
    LatLng? loc;
    try {
      loc = await _locationService.getCurrentPosition();
    } on LocationFailure {
      loc = _userLocation;
    } catch (_) {
      loc = _userLocation;
    }

    if (!mounted) return;

    if (loc == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Konum yok'),
          content: const Text(
            'GPS konumu alınamadı. Acil isteği konum olmadan oluşturmak istiyor musunuz? '
            'Gerçek acil servis aranmayacaktır; kayıt yalnızca yerelde tutulur.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Devam et'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('SOS onayı'),
          content: Text(
            'Acil destek isteği oluşturulsun mu?\n'
            'Konum: ${loc!.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}\n\n'
            'Gerçek arama/SMS gönderilmez. Güvenilir kişinize bildirim entegrasyonu sonraki sürümde.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: YanYanaColors.sos),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('SOS Oluştur'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      final req = await _backend.triggerSOS(
        latitude: loc?.latitude,
        longitude: loc?.longitude,
      );
      if (!mounted) return;
      final point = req.latLng;
      if (point != null) {
        _mapController.move(point, 15);
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Acil istek oluşturuldu'),
          content: Text(
            'Durum: ${req.statusLabel}\n'
            '${req.location != null ? 'Konum haritada işaretlendi.\n' : 'Konum olmadan kaydedildi.\n'}'
            'Bu yalnızca yerel MVP kaydıdır; gerçek arama/SMS gönderilmez.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _openFilterSheet() {
    showMapFilterSheet(
      context: context,
      initialCategory: _categoryFilter,
      initialAccessibilityFilters: _accessibilityFilters,
      accessFilterOptions: _accessFilterOptions,
      onApply: (category, filters) {
        setState(() {
          _categoryFilter = category;
          _accessibilityFilters
            ..clear()
            ..addAll(filters);
        });
      },
    );
  }

  double _listBottomPadding(BuildContext context) {
    // Map tab body sits above MainPage bottom nav; only safe-area inset needed.
    return MediaQuery.paddingOf(context).bottom + 12;
  }

  void _openEmergencyDetails(EmergencyRequest request) {
    showEmergencyRequestSheet(
      context: context,
      request: request,
      onDismiss: () async {
        await _backend.dismissMapEmergencyRequest(
          request.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acil işaret haritadan kaldırıldı.'),
            ),
          );
        }
      },
    );
  }

  List<Marker> _buildEmergencyMarkers() {
    return _emergencyRequests
        .where((r) => r.latLng != null)
        .map(
          (r) => Marker(
            point: r.latLng!,
            width: 130,
            height: 95,
            alignment: Alignment.topCenter,
            child: EmergencyMapMarker(
              request: r,
              onTap: () => _openEmergencyDetails(r),
            ),
          ),
        )
        .toList();
  }

  List<Marker> _buildMarkers(List<AccessiblePlace> places) {
    return places
        .map(
          (p) => Marker(
            point: LatLng(p.latitude, p.longitude),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _selectPlace(p),
              child: Icon(
                Icons.location_on_rounded,
                size: 44,
                color: p.color,
                semanticLabel: p.name,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlaces;
    final sortedList = sortPlacesForList(filtered, _listSort);
    final listBottomPad = _listBottomPadding(context);
    final hasPlaces = _allPlaces.isNotEmpty;

    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        toolbarHeight: 52,
        centerTitle: false,
        title: const Text(
          'Erişilebilir Harita',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: YanYanaColors.textDark,
          ),
        ),
        backgroundColor: YanYanaColors.surface,
        foregroundColor: YanYanaColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          Semantics(
            label: 'Erişilebilir rota, gelecek özellik',
            button: true,
            child: IconButton(
              tooltip: 'Erişilebilir rota (gelecek)',
              icon: const Icon(Icons.directions_walk_outlined, size: 24),
              onPressed: () => showFutureFeatureDialog(
                context,
                title: 'Erişilebilir rota',
                message:
                    'Gelişmiş rota erişilebilirlik analizi gelecek sürümde eklenecek.',
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LocationService.defaultCenter,
              initialZoom: 13,
              onMapReady: () => setState(() => _mapReady = true),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.yanyana_p',
                errorTileCallback: (tile, error, stackTrace) {
                  if (_mapError == null && mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _mapError =
                              'Harita karoları yüklenemedi. İnternet bağlantınızı kontrol edin.';
                        });
                      }
                    });
                  }
                },
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: YanYanaColors.accentBlue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: YanYanaColors.accentBlue,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: YanYanaColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers(filtered)),
              if (_emergencyRequests.isNotEmpty)
                MarkerLayer(markers: _buildEmergencyMarkers()),
            ],
                ),
              ),
              if (!_mapReady || _loading)
                Positioned.fill(
                  child: Container(
                    color: YanYanaColors.background.withValues(alpha: 0.85),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Harita yükleniyor…',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: YanYanaColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_mapError != null)
                Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: YanYanaColors.warning.withValues(alpha: 0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mapError!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _mapError = null),
                      ),
                    ],
                  ),
                ),
              ),
                ),
              Positioned(
                top: 6,
                left: 12,
                right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 1,
                  shadowColor: Colors.black12,
                  borderRadius: BorderRadius.circular(14),
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchLocation(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mekan veya semt ara…',
                      hintStyle: TextStyle(
                        color: YanYanaColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: YanYanaColors.textMuted.withValues(alpha: 0.8),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchingLocation)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else
                            IconButton(
                              tooltip: 'Semt veya konum ara',
                              icon: const Icon(Icons.travel_explore_rounded, size: 22),
                              onPressed: _searchLocation,
                            ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: YanYanaColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: YanYanaColors.border),
                      ),
                      filled: true,
                      fillColor: YanYanaColors.surface,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Kayıtlı mekanlar listesi',
                        button: true,
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(12),
                          color: YanYanaColors.primary.withValues(alpha: 0.92),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _openSavedPlacesPanel,
                            child: SizedBox(
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.bookmark_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Kayıtlı (${sortedList.length})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: 'Harita filtreleri',
                        button: true,
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(12),
                          color: YanYanaColors.surface,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _openFilterSheet,
                            child: SizedBox(
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 18,
                                    color: _categoryFilter != 'Tümü' ||
                                            _accessibilityFilters.isNotEmpty
                                        ? YanYanaColors.primary
                                        : YanYanaColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _categoryFilter != 'Tümü' ||
                                              _accessibilityFilters.isNotEmpty
                                          ? 'Filtre · Aktif'
                                          : 'Filtre',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _categoryFilter != 'Tümü' ||
                                                _accessibilityFilters.isNotEmpty
                                            ? YanYanaColors.primary
                                            : YanYanaColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: mapHeight,
                child: _SavedPlacesSheet(
                  key: _placesSheetKey,
                  mapHeight: mapHeight,
                  hasPlaces: hasPlaces,
                  sheetExtent: _sheetExtent,
                  places: sortedList,
                  sort: _listSort,
                  bottomPadding: listBottomPad,
                  selectedPlaceId: _selectedPlaceId,
                  onAddPlace: _openAddPlace,
                  onSortChanged: (s) => setState(() => _listSort = s),
                  onPlaceSelected: _selectPlace,
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, fraction, _) {
                  final fabBottom =
                      (mapHeight * fraction + 16).clamp(72.0, mapHeight - 160);
                  return Positioned(
                    right: 12,
                    bottom: fabBottom,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MapCompactFab(
                          label: 'SOS',
                          icon: Icons.emergency_rounded,
                          color: const Color(0xFFDC4C4C),
                          semanticLabel: 'Acil SOS isteği oluştur',
                          onPressed: _triggerSos,
                        ),
                        const SizedBox(height: 8),
                        MapCompactFab(
                          label: 'Ekle',
                          icon: Icons.add_location_alt_outlined,
                          color: YanYanaColors.primary.withValues(alpha: 0.95),
                          semanticLabel: 'Erişilebilir mekan ekle',
                          onPressed: _openAddPlace,
                        ),
                        const SizedBox(height: 8),
                        MapCompactFab(
                          label: 'Konum',
                          icon: Icons.my_location_rounded,
                          color: YanYanaColors.secondary.withValues(alpha: 0.95),
                          semanticLabel: 'Konumumu göster',
                          onPressed: _showMyLocation,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Owns [DraggableScrollableController] so parent [setState] does not re-attach it.
class _SavedPlacesSheet extends StatefulWidget {
  const _SavedPlacesSheet({
    super.key,
    required this.mapHeight,
    required this.hasPlaces,
    required this.sheetExtent,
    required this.places,
    required this.sort,
    required this.bottomPadding,
    required this.selectedPlaceId,
    required this.onAddPlace,
    required this.onSortChanged,
    required this.onPlaceSelected,
  });

  final double mapHeight;
  final bool hasPlaces;
  final ValueNotifier<double> sheetExtent;
  final List<AccessiblePlace> places;
  final PlaceListSort sort;
  final double bottomPadding;
  final String? selectedPlaceId;
  final VoidCallback onAddPlace;
  final ValueChanged<PlaceListSort> onSortChanged;
  final void Function(AccessiblePlace place) onPlaceSelected;

  @override
  State<_SavedPlacesSheet> createState() => _SavedPlacesSheetState();
}

class _SavedPlacesSheetState extends State<_SavedPlacesSheet> {
  static const _sheetKey = ValueKey<String>('saved_places_draggable_sheet');
  static const _minSize = 0.12;
  static const _initialSize = 0.14;
  static const _maxSize = 0.52;

  final _controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    widget.sheetExtent.value = _initialSize;
    _controller.addListener(_onSheetMoved);
  }

  void _onSheetMoved() {
    if (_controller.isAttached) {
      widget.sheetExtent.value = _controller.size;
    }
  }

  void expand() {
    if (_controller.isAttached) {
      _controller.animateTo(
        0.45,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSheetMoved);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: _sheetKey,
      controller: _controller,
      initialChildSize: _initialSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      snapSizes: const [_minSize, _initialSize, 0.24, 0.38, _maxSize],
      builder: (context, scrollController) {
        return PlaceListPanel(
          places: widget.places,
          scrollController: scrollController,
          sort: widget.sort,
          hasAnyPlaces: widget.hasPlaces,
          bottomPadding: widget.bottomPadding,
          selectedPlaceId: widget.selectedPlaceId,
          onAddPlace: widget.onAddPlace,
          onSortChanged: widget.onSortChanged,
          onPlaceSelected: widget.onPlaceSelected,
        );
      },
    );
  }
}
