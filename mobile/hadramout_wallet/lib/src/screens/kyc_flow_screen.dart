import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../api_service.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home_screen.dart';

class KycFlowScreen extends StatefulWidget {
  const KycFlowScreen({
    required this.apiService,
    required this.session,
    super.key,
  });

  final ApiService apiService;
  final UserSession session;

  @override
  State<KycFlowScreen> createState() => _KycFlowScreenState();
}

class _KycFlowScreenState extends State<KycFlowScreen> {
  static const _totalSteps = 11;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _residenceController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _documentExpiryController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _incomeController = TextEditingController();

  int _step = 0;
  DateTime? _birthDate;
  DateTime? _documentExpiry;
  String? _gender;
  String? _documentType;
  String? _employment;
  String? _incomeSource;
  String? _frontImagePath;
  String? _backImagePath;
  String? _selfieImagePath;
  bool _acceptedTerms = false;
  String? _stepError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _residenceController.dispose();
    _documentNumberController.dispose();
    _documentExpiryController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (date == null) return;
    setState(() {
      _birthDate = date;
      _birthDateController.text = DateFormat('yyyy/MM/dd').format(date);
    });
  }

  Future<void> _selectDocumentExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      helpText: 'اختر تاريخ انتهاء الوثيقة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (date == null) return;
    setState(() {
      _documentExpiry = date;
      _documentExpiryController.text = DateFormat('yyyy/MM/dd').format(date);
    });
  }

  Future<void> _pickImage({
    required ImageSource source,
    required void Function(String path) onSelected,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (image != null && mounted) {
      setState(() => onSelected(image.path));
    }
  }

  bool _validateCurrentStep() {
    setState(() => _stepError = null);

    switch (_step) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 6:
      case 7:
      case 8:
      case 9:
        return _formKey.currentState?.validate() ?? false;
      case 4:
        return _requireValue(_frontImagePath, 'أضف صورة الوجه الأمامي للوثيقة');
      case 5:
        return _requireValue(_backImagePath, 'أضف صورة الوجه الخلفي للوثيقة');
      case 10:
        return _requireValue(
          _acceptedTerms ? 'accepted' : null,
          'يجب الموافقة على الإقرار لإرسال الطلب',
        );
      default:
        return true;
    }
  }

  bool _requireValue(String? value, String message) {
    if (value != null && value.isNotEmpty) return true;
    setState(() => _stepError = message);
    return false;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_step == _totalSteps - 1) {
      _completeKyc();
      return;
    }
    setState(() => _step += 1);
  }

  void _previous() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _step -= 1;
      _stepError = null;
    });
  }

  Future<void> _completeKyc() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: WalletColors.success,
          size: 48,
        ),
        title: const Text('اكتملت مراجعة البيانات'),
        content: const Text(
          'تمت مراجعة بياناتك على الجهاز بنجاح. سيصبح إرسال الطلب للمراجعة متاحاً عند إضافة واجهة KYC الآمنة إلى الخادم.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('العودة للمحفظة'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(apiService: widget.apiService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WalletScaffold(
      title: 'التحقق من الهوية',
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: StepProgress(current: _step + 1, total: _totalSteps),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: _buildStep(),
                ),
              ),
              _BottomActions(
                onBack: _previous,
                onNext: _next,
                isLast: _step == _totalSteps - 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildPersonalDetails();
      case 1:
        return _buildResidency();
      case 2:
        return _buildDocumentType();
      case 3:
        return _buildDocumentDetails();
      case 4:
        return _buildDocumentUpload(
          title: 'صورة الوجه الأمامي',
          description: 'التقط صورة واضحة للوجه الأمامي من هويتك.',
          path: _frontImagePath,
          onCamera: () => _pickImage(
            source: ImageSource.camera,
            onSelected: (path) => _frontImagePath = path,
          ),
          onGallery: () => _pickImage(
            source: ImageSource.gallery,
            onSelected: (path) => _frontImagePath = path,
          ),
        );
      case 5:
        return _buildDocumentUpload(
          title: 'صورة الوجه الخلفي',
          description: 'التقط صورة واضحة للوجه الخلفي من هويتك.',
          path: _backImagePath,
          onCamera: () => _pickImage(
            source: ImageSource.camera,
            onSelected: (path) => _backImagePath = path,
          ),
          onGallery: () => _pickImage(
            source: ImageSource.gallery,
            onSelected: (path) => _backImagePath = path,
          ),
        );
      case 6:
        return _buildSelfie();
      case 7:
        return _buildAddress();
      case 8:
        return _buildEmployment();
      case 9:
        return _buildFinancialDetails();
      case 10:
        return _buildReview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalDetails() {
    return _stepContent(
      title: 'بياناتك الشخصية',
      subtitle: 'لنبدأ بالمعلومات الأساسية كما تظهر في وثيقتك الرسمية.',
      children: [
        _field(
          controller: _fullNameController,
          label: 'الاسم الكامل',
          icon: Icons.person_outline_rounded,
          validator: (value) => value == null || value.trim().length < 3
              ? 'أدخل الاسم الكامل'
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          onTap: _selectBirthDate,
          decoration: const InputDecoration(
            labelText: 'تاريخ الميلاد',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
          validator: (_) => _birthDate == null ? 'اختر تاريخ الميلاد' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(
            labelText: 'الجنس',
            prefixIcon: Icon(Icons.wc_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('ذكر')),
            DropdownMenuItem(value: 'female', child: Text('أنثى')),
          ],
          onChanged: (value) => setState(() => _gender = value),
          validator: (value) => value == null ? 'اختر الجنس' : null,
        ),
      ],
    );
  }

  Widget _buildResidency() {
    return _stepContent(
      title: 'الجنسية والإقامة',
      subtitle: 'تساعدنا هذه المعلومات على تطبيق المتطلبات النظامية المناسبة.',
      children: [
        _field(
          controller: _nationalityController,
          label: 'الجنسية',
          icon: Icons.flag_outlined,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'أدخل الجنسية' : null,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _residenceController,
          label: 'بلد الإقامة',
          icon: Icons.public_outlined,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'أدخل بلد الإقامة' : null,
        ),
      ],
    );
  }

  Widget _buildDocumentType() {
    return _stepContent(
      title: 'وثيقة إثبات الهوية',
      subtitle: 'اختر الوثيقة التي ستستخدمها لإكمال التحقق.',
      children: [
        DropdownButtonFormField<String>(
          value: _documentType,
          decoration: const InputDecoration(
            labelText: 'نوع الوثيقة',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          items: const [
            DropdownMenuItem(
                value: 'national_id', child: Text('بطاقة الهوية الوطنية')),
            DropdownMenuItem(value: 'passport', child: Text('جواز السفر')),
            DropdownMenuItem(value: 'residence', child: Text('بطاقة الإقامة')),
          ],
          onChanged: (value) => setState(() => _documentType = value),
          validator: (value) => value == null ? 'اختر نوع الوثيقة' : null,
        ),
        const SizedBox(height: 18),
        const InfoBanner(
          message:
              'تأكد من أن الوثيقة سارية، وأن الصور واضحة وجميع البيانات ظاهرة.',
        ),
      ],
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String description,
    required String? path,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return _stepContent(
      title: title,
      subtitle: description,
      children: [
        _ImagePickerCard(
          path: path,
          onCamera: onCamera,
          onGallery: onGallery,
        ),
      ],
    );
  }

  Widget _buildDocumentDetails() {
    return _stepContent(
      title: 'تفاصيل الوثيقة',
      subtitle: 'أدخل رقم الوثيقة وتاريخ انتهائها كما يظهران في الوثيقة.',
      children: [
        _field(
          controller: _documentNumberController,
          label: 'رقم الوثيقة',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.text,
          validator: (value) => value == null || value.trim().length < 5
              ? 'أدخل رقم الوثيقة'
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _documentExpiryController,
          readOnly: true,
          onTap: _selectDocumentExpiry,
          decoration: const InputDecoration(
            labelText: 'تاريخ انتهاء الوثيقة',
            prefixIcon: Icon(Icons.event_available_outlined),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
          validator: (_) =>
              _documentExpiry == null ? 'اختر تاريخ انتهاء الوثيقة' : null,
        ),
      ],
    );
  }

  Widget _buildSelfie() {
    return _stepContent(
      title: 'صورة شخصية للتحقق',
      subtitle: 'التقط صورة مباشرة لوجهك دون نظارات أو غطاء للوجه.',
      children: [
        _ImagePickerCard(
          path: _selfieImagePath,
          onCamera: () => _pickImage(
            source: ImageSource.camera,
            onSelected: (path) => _selfieImagePath = path,
          ),
          onGallery: () => _pickImage(
            source: ImageSource.gallery,
            onSelected: (path) => _selfieImagePath = path,
          ),
          circular: true,
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          message:
              'استخدم إضاءة جيدة وانظر مباشرة إلى الكاميرا للحصول على أفضل نتيجة.',
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return _stepContent(
      title: 'عنوان السكن',
      subtitle: 'أدخل عنوان إقامتك الحالي بالتفصيل.',
      children: [
        _field(
          controller: _cityController,
          label: 'المدينة',
          icon: Icons.location_city_outlined,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'أدخل المدينة' : null,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _districtController,
          label: 'الحي / المنطقة',
          icon: Icons.map_outlined,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'أدخل الحي أو المنطقة'
              : null,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _streetController,
          label: 'الشارع والعنوان التفصيلي',
          icon: Icons.home_outlined,
          maxLines: 2,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'أدخل العنوان التفصيلي'
              : null,
        ),
      ],
    );
  }

  Widget _buildEmployment() {
    return _stepContent(
      title: 'العمل والدخل',
      subtitle: 'هذه المعلومات تساعدنا على فهم استخدامك المتوقع للمحفظة.',
      children: [
        DropdownButtonFormField<String>(
          value: _employment,
          decoration: const InputDecoration(
            labelText: 'الحالة الوظيفية',
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
          items: const [
            DropdownMenuItem(value: 'employed', child: Text('موظف')),
            DropdownMenuItem(value: 'business', child: Text('صاحب عمل')),
            DropdownMenuItem(value: 'student', child: Text('طالب')),
            DropdownMenuItem(value: 'retired', child: Text('متقاعد')),
            DropdownMenuItem(value: 'other', child: Text('أخرى')),
          ],
          onChanged: (value) => setState(() => _employment = value),
          validator: (value) => value == null ? 'اختر الحالة الوظيفية' : null,
        ),
      ],
    );
  }

  Widget _buildFinancialDetails() {
    return _stepContent(
      title: 'مصدر الأموال',
      subtitle: 'اختر المصدر الأقرب لطبيعة استخدامك للمحفظة.',
      children: [
        DropdownButtonFormField<String>(
          value: _incomeSource,
          decoration: const InputDecoration(
            labelText: 'مصدر الدخل الرئيسي',
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'salary', child: Text('راتب')),
            DropdownMenuItem(value: 'business', child: Text('نشاط تجاري')),
            DropdownMenuItem(value: 'savings', child: Text('مدخرات')),
            DropdownMenuItem(value: 'family', child: Text('دعم عائلي')),
            DropdownMenuItem(value: 'other', child: Text('مصدر آخر')),
          ],
          onChanged: (value) => setState(() => _incomeSource = value),
          validator: (value) => value == null ? 'اختر مصدر الدخل' : null,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _incomeController,
          label: 'الدخل الشهري التقريبي',
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'أدخل الدخل التقريبي'
              : null,
        ),
      ],
    );
  }

  Widget _buildReview() {
    return _stepContent(
      title: 'المراجعة والإقرار',
      subtitle: 'راجع بياناتك قبل إرسال طلب التحقق.',
      children: [
        _ReviewTile(label: 'الاسم', value: _fullNameController.text),
        _ReviewTile(label: 'الجنسية', value: _nationalityController.text),
        _ReviewTile(label: 'الوثيقة', value: _documentLabel),
        _ReviewTile(
            label: 'رقم الوثيقة', value: _documentNumberController.text),
        _ReviewTile(
            label: 'العنوان',
            value: '${_cityController.text}، ${_districtController.text}'),
        _ReviewTile(label: 'مصدر الدخل', value: _incomeSourceLabel),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WalletColors.border),
          ),
          child: CheckboxListTile(
            value: _acceptedTerms,
            onChanged: (value) =>
                setState(() => _acceptedTerms = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: WalletColors.blue,
            title: const Text(
              'أقر بأن المعلومات المقدمة صحيحة وأوافق على سياسة التحقق.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String get _documentLabel {
    switch (_documentType) {
      case 'passport':
        return 'جواز السفر';
      case 'residence':
        return 'بطاقة الإقامة';
      default:
        return 'بطاقة الهوية الوطنية';
    }
  }

  String get _incomeSourceLabel {
    switch (_incomeSource) {
      case 'salary':
        return 'راتب';
      case 'business':
        return 'نشاط تجاري';
      case 'savings':
        return 'مدخرات';
      case 'family':
        return 'دعم عائلي';
      default:
        return 'مصدر آخر';
    }
  }

  Widget _stepContent({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(title: title, subtitle: subtitle),
        const SizedBox(height: 24),
        ...children,
        if (_stepError != null) ...[
          const SizedBox(height: 15),
          Text(
            _stepError!,
            style: const TextStyle(color: WalletColors.danger, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.path,
    required this.onCamera,
    required this.onGallery,
    this.circular = false,
  });

  final String? path;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 210,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: WalletColors.paleBlue,
            borderRadius: BorderRadius.circular(circular ? 105 : 22),
            border: Border.all(color: WalletColors.border),
          ),
          child: path == null
              ? const Center(
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: WalletColors.blue,
                    size: 46,
                  ),
                )
              : Image.file(File(path!), fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('التقاط صورة'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('من المعرض'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: WalletColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: WalletColors.muted, fontSize: 12),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: WalletColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onBack,
    required this.onNext,
    required this.isLast,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: WalletColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('السابق'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon:
                  Icon(isLast ? Icons.check_rounded : Icons.arrow_back_rounded),
              label: Text(isLast ? 'إرسال الطلب' : 'التالي'),
            ),
          ),
        ],
      ),
    );
  }
}
