import 'package:flutter/material.dart';

class CustomFormField extends FormField<String> {
  final String label;
  final int maxLines;
  final int maxLength;
  final InputDecoration decoration;

  CustomFormField({
    Key key,
    @required String value,
    @required this.label,
    @required this.maxLines,
    @required this.maxLength,
    @required this.decoration,
    @required FormFieldValidator<String> validator,
    @required FormFieldSetter<String> onSaved,
  })  : assert(decoration != null),
        assert(label != null),
        assert(maxLength == null || maxLength > 0),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: value,
          validator: validator,
          autovalidateMode: AutovalidateMode.always,
          builder: (FormFieldState<String> field) {
            final effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );

            return InputDecorator(
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
              ),
              isEmpty: value?.isEmpty ?? true,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );

  @override
  FormFieldState<String> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends FormFieldState<String> {
  bool _isTapDoneButton = false;
  final _textChangedNotifier = ValueNotifier<String>(null);
  final _textController = TextEditingController();

  @override
  CustomFormField get widget => super.widget as CustomFormField;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(context),
      child: super.build(context),
    );
  }

  void _handleTap(BuildContext context) {
    FocusScope.of(context).unfocus();
    final initText = widget.initialValue ?? '';
    _textChangedNotifier.value = initText;
    _textController.text = initText;

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      builder: _textFieldModalSheet,
    ).whenComplete(() {
      // NOTE: 完了するボタンを押さずに選択画面を閉じた場合は選択前に戻す
      if (!_isTapDoneButton) {
        super.reset();
        super.save();
      }
    });
  }

  Widget _textFieldModalSheet(BuildContext context) {
    const paddingSpace = 16.0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: paddingSpace) +
            MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: paddingSpace,
                right: paddingSpace / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: _textChangedNotifier,
                    builder: (context, editingText, __) {
                      final enableDoneButton =
                          editingText.characters.length <= widget.maxLength;
                      return FlatButton(
                        textTheme: ButtonTextTheme.primary,
                        child: Text(
                          '完了する',
                          style: TextStyle(
                            fontWeight: enableDoneButton
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onPressed: enableDoneButton
                            ? () {
                                _isTapDoneButton = true;
                                super.setValue(editingText);
                                super.save();
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              }
                            : null,
                      );
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: paddingSpace,
              ),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                maxLengthEnforced: false,
                decoration: InputDecoration(
                  hintText: '例：コロナで大変でしたね 😥',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
                onChanged: (v) => _textChangedNotifier.value = v,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
