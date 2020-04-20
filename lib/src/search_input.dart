import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_location_picker/generated/i18n.dart';

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  SearchInput(
    this.onSearchInput, {
    Key key,
    this.onDone,
    this.searchInputKey,
    this.boxDecoration,
    this.hintText,
  }) : super(key: key);

  final ValueChanged<String> onSearchInput;
  final ValueChanged<String> onDone;
  final Key searchInputKey;
  final BoxDecoration boxDecoration;
  final String hintText;

  @override
  State<StatefulWidget> createState() => SearchInputState();
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer debouncer;

  bool hasSearchEntry = false;

  @override
  void initState() {
    super.initState();
    editController.addListener(onSearchInputChange);
  }

  @override
  void dispose() {
    editController.removeListener(onSearchInputChange);
    editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (editController.text.isEmpty) {
      debouncer?.cancel();
      widget.onSearchInput(editController.text);
      return;
    }

    if (debouncer?.isActive ?? false) {
      debouncer.cancel();
    }

    debouncer = Timer(Duration(milliseconds: 500), () {
      widget.onSearchInput(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.boxDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.white,
          ),
      padding: EdgeInsets.all(3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                suffixIcon: hasSearchEntry
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          editController.clear();
                          setState(() {
                            hasSearchEntry = false;
                          });
                        },
                      )
                    : null,
                hintText: widget.hintText ?? S.of(context)?.search_place,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  hasSearchEntry = value.isNotEmpty;
                });
              },
              onEditingComplete: () {
                if (widget.onDone != null) {
                  widget.onDone(editController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
