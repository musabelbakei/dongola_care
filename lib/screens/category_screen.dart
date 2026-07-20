import 'package:flutter/material.dart';
import '../models/facility_model.dart';
import '../services/db_helper.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_app_bar.dart';
import 'details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String facilityType;
  const CategoryScreen(
      {super.key, required this.categoryTitle, required this.facilityType});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final DBHelper db = DBHelper.instance;
  List<FacilityModel> allFacilities = [];
  List<FacilityModel> filteredFacilities = [];
  bool loading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'الكل';
  List<String> filterOptions = ['الكل'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      List<FacilityModel> data;

      if (widget.facilityType == 'health_group') {
        data = (await db.getAllFacilities())
            .where((f) =>
                !f.facilityType.contains('صيدلية') &&
                !f.facilityType.contains('معمل'))
            .toList();
        final types = data.map((f) => f.facilityType).toSet().toList();
        filterOptions = ['الكل', ...types];
      } else {
        data = await db.getFacilitiesByType(widget.facilityType);
        filterOptions = ['الكل'];
      }

      if (!mounted) return;
      setState(() {
        allFacilities = data;
        filteredFacilities = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'تعذّر تحميل البيانات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  void _applyFilters() {
    String query = searchController.text.trim().toLowerCase();
    List<FacilityModel> results = List.from(allFacilities);

    if (selectedFilter != 'الكل') {
      results = results.where((f) => f.facilityType == selectedFilter).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((f) {
        return f.facilityName.toLowerCase().contains(query) ||
            (f.neighborhood?.toLowerCase().contains(query) ?? false) ||
            (f.street?.toLowerCase().contains(query) ?? false) ||
            (f.landmark?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() {
      filteredFacilities = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: widget.categoryTitle),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، الحي، أو الشارع...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            _applyFilters();
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            if (filterOptions.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final filter = filterOptions[index];
                      final isSelected = selectedFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => selectedFilter = filter);
                          _applyFilters();
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.primary),
                        backgroundColor: AppColors.primaryLight,
                        side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3)),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : errorMessage != null
                      ? _buildErrorState()
                      : filteredFacilities.isEmpty
                          ? const Center(child: Text('لا توجد مرافق مطابقة'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredFacilities.length,
                              itemBuilder: (_, i) => Card(
                                elevation: 4,
                                shadowColor: AppColors.cardShadow,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: Hero(
                                    tag:
                                        'facility_image_${filteredFacilities[i].facilityId}',
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      backgroundImage: AssetImage(
                                          filteredFacilities[i].imagePath),
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                  ),
                                  title: Text(
                                    filteredFacilities[i].facilityName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text(filteredFacilities[i].addressLine),
                                  trailing: const Icon(Icons.arrow_back_ios,
                                      size: 16),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailsScreen(
                                          facility: filteredFacilities[i]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
