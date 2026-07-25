/// Screen for creating and editing linear ratio custom converters.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/custom_converter.dart';
import '../providers/custom_converter_provider.dart';
import '../services/refresh_service.dart';
import '../widgets/empty_state_widget.dart';

class CustomConverterScreen extends StatelessWidget {
  const CustomConverterScreen({super.key});

  void _openEditor(BuildContext context, [CustomConverter? converter]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CustomConverterEditor(converter: converter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<CustomConverterProvider>();
    final converters = provider.converters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Converters'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Converter'),
      ),
      body: RefreshIndicator(
        onRefresh: () => RefreshService.refreshApp(context),
        child: converters.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateWidget(
                    icon: Icons.dashboard_customize_outlined,
                    message: 'No Custom Converters',
                    subtitle: 'Create custom linear unit groups like "1 Box = 24 Bottles".',
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: converters.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = converters[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.delete_rounded, color: colorScheme.onErrorContainer),
                    ),
                    onDismissed: (_) {
                      HapticFeedback.mediumImpact();
                      provider.delete(item.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text('${item.units.length} defined units'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit converter',
                          onPressed: () => _openEditor(context, item),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CustomConverterEditor extends StatefulWidget {
  final CustomConverter? converter;

  const _CustomConverterEditor({this.converter});

  @override
  State<_CustomConverterEditor> createState() => _CustomConverterEditorState();
}

class _CustomConverterEditorState extends State<_CustomConverterEditor> {
  final _nameCtrl = TextEditingController();
  String _emoji = '📐';
  final List<CustomUnit> _units = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.converter != null) {
      _nameCtrl.text = widget.converter!.name;
      _emoji = widget.converter!.emoji;
      _units.addAll(widget.converter!.units);
    } else {
      // Default base unit
      _units.add(const CustomUnit(name: 'Base Unit', symbol: 'base', toBase: 1.0));
      _units.add(const CustomUnit(name: 'Box', symbol: 'bx', toBase: 24.0));
    }
  }

  void _addUnitDialog() {
    final uNameCtrl = TextEditingController();
    final uSymCtrl = TextEditingController();
    final uBaseCtrl = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: uNameCtrl,
              decoration: const InputDecoration(labelText: 'Unit Name (e.g. Carton)'),
            ),
            TextField(
              controller: uSymCtrl,
              decoration: const InputDecoration(labelText: 'Symbol (e.g. ctn)'),
            ),
            TextField(
              controller: uBaseCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Ratio to Base Unit (e.g. 12)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = uNameCtrl.text.trim();
              final sym = uSymCtrl.text.trim();
              final ratio = double.tryParse(uBaseCtrl.text.trim()) ?? 1.0;
              if (name.isEmpty) return;
              setState(() {
                _units.add(CustomUnit(name: name, symbol: sym.isEmpty ? name : sym, toBase: ratio));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _units.length < 2) return;
    final provider = context.read<CustomConverterProvider>();
    if (widget.converter == null) {
      provider.create(name: name, emoji: _emoji, units: _units);
    } else {
      provider.update(CustomConverter(
        id: widget.converter!.id,
        name: name,
        emoji: _emoji,
        units: _units,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converter == null ? 'Create Converter' : 'Edit Converter'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Converter Name',
              hintText: 'e.g. Packaging Units',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Defined Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addUnitDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Unit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._units.asMap().entries.map((entry) {
            final idx = entry.key;
            final u = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${u.name} (${u.symbol})'),
                subtitle: Text('1 ${u.name} = ${u.toBase} base units'),
                trailing: _units.length > 2
                    ? IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
                        tooltip: 'Remove unit',
                        onPressed: () => setState(() => _units.removeAt(idx)),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
