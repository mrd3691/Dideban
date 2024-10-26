import 'package:flutter/material.dart';

enum CheckBoxState {
  selected,
  unselected,
  partial,
}

class TitleCheckBox extends StatelessWidget {
  const TitleCheckBox({
    Key? key,
    required this.title,
    required this.checkBoxState,
    required this.onChanged,
    required this.level,
    required this.onTap
  }) : super(key: key);

  final String title;
  final CheckBoxState checkBoxState;
  final VoidCallback onChanged;
  final int level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    const size = 24.0;
    const borderRadius = BorderRadius.all(Radius.circular(3.0));
    return Row(
      children: [
        SizedBox(
          width: level * 16.0,
        ),
        IconButton(
          onPressed: onChanged,
          // borderRadius: borderRadius,
          icon: Container(
            height: size,
            width: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: checkBoxState == CheckBoxState.unselected
                    ? themeData.unselectedWidgetColor
                    : themeData.primaryColor,
                width: 2.0,
              ),
              borderRadius: borderRadius,
              color: checkBoxState == CheckBoxState.unselected
                  ? Colors.transparent
                  : themeData.primaryColor,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 260,
              ),
              child: checkBoxState == CheckBoxState.unselected
                  ? const SizedBox(
                height: size,
                width: size,
              )
                  : FittedBox(
                key: ValueKey(checkBoxState.name),
                fit: BoxFit.scaleDown,
                child: Center(
                  child: checkBoxState == CheckBoxState.partial
                      ? Container(
                    height: 1.8,
                    width: 12.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: borderRadius,
                    ),
                  )
                      : const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8.0,
        ),
        InkWell(
          onTap: onTap,
            child: Text(title,style: TextStyle(fontSize: 12),)),
      ],
    );
  }
}

class TreeNode {
  late String title;
  final bool isSelected;
  final CheckBoxState checkBoxState;
  late  List<TreeNode> children;

  TreeNode({
    required this.title,
    this.isSelected = false,
    this.children = const <TreeNode>[],
  }) : checkBoxState = isSelected
      ? CheckBoxState.selected
      : (children.any((element) =>
  element.checkBoxState != CheckBoxState.unselected)
      ? CheckBoxState.partial
      : CheckBoxState.unselected);

  TreeNode copyWith({
    String? title,
    bool? isSelected,
    List<TreeNode>? children,
  }) {
    return TreeNode(
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
      children: children ?? this.children,
    );
  }
}

class TreeView extends StatefulWidget {
  const TreeView({
    Key? key,
    required this.nodes,
    this.level = 0,
    required this.onChanged,
    required this.onTap
  }) : super(key: key);

  final List<TreeNode> nodes;
  final int level;
  final void Function(List<TreeNode> newNodes) onChanged;
  final void Function(TreeNode node) onTap;

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  late List<TreeNode> nodes;

  @override
  void initState() {
    super.initState();
    nodes = widget.nodes;
  }

  TreeNode _unselectAllSubTree(TreeNode node) {
    final treeNode = node.copyWith(
      isSelected: false,
      children: node.children.isEmpty
          ? null
          : node.children.map((e) => _unselectAllSubTree(e)).toList(),
    );
    return treeNode;
  }

  TreeNode _selectAllSubTree(TreeNode node) {
    final treeNode = node.copyWith(
      isSelected: true,
      children: node.children.isEmpty
          ? null
          : node.children.map((e) => _selectAllSubTree(e)).toList(),
    );
    return treeNode;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes != nodes) {
      nodes = widget.nodes;
    }

    return ListView.builder(
      itemCount: nodes.length,
      physics: widget.level != 0 ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.level != 0,
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: TitleCheckBox(
            onChanged: () {
              switch (nodes[index].checkBoxState) {
                case CheckBoxState.selected:
                  nodes[index] = _unselectAllSubTree(nodes[index]);
                  break;
                case CheckBoxState.unselected:
                  nodes[index] = _selectAllSubTree(nodes[index]);
                  break;
                case CheckBoxState.partial:
                  nodes[index] = _unselectAllSubTree(nodes[index]);
                  break;
              }
              if (widget.level == 0) {
                setState(() {});
              }
              widget.onChanged(nodes);
            },
            onTap: (){
              var y =nodes[index];
              var t =0;
              widget.onTap(nodes[index]);

            },
            title: nodes[index].title ,
            checkBoxState: nodes[index].checkBoxState,
            level: widget.level,

          ),
          trailing:
          nodes[index].children.isEmpty ? const SizedBox.shrink() : null,
          children: [
            TreeView(
              nodes: nodes[index].children,
              level: widget.level + 1,
              onChanged: (newNodes) {
                bool areAllItemsSelected = !nodes[index]
                    .children
                    .any((element) => !element.isSelected);

                nodes[index] = nodes[index].copyWith(
                  isSelected: areAllItemsSelected,
                  children: newNodes,
                );

                widget.onChanged(nodes);
                if (widget.level == 0) {
                  setState(() {});
                }
              }, onTap: (value) {
                var yyyy= nodes[index];
                var mmm=0;
                widget.onTap(value);
            },
            ),
          ],
        );
      },
    );
  }
}