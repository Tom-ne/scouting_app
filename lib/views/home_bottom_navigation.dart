import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final PageController pageController;
  final void Function(int)? onTap;
  final Color? fixedColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const HomeBottomNavigationBar({
    super.key,
    required this.items,
    required this.pageController,
    this.onTap,
    this.fixedColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  State<HomeBottomNavigationBar> createState() => _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  late int pageIndex;

  void _fetchPageIndex() {
    pageIndex = widget.pageController.page?.round() ?? widget.pageController.initialPage;
  }
  
  @override
  void initState() {
    _fetchPageIndex();
    widget.pageController.addListener(_updatePage);
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_updatePage);
    super.dispose();
  }

  void _updatePage() {
    setState(() {
      _fetchPageIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: widget.items,
      currentIndex: pageIndex,
      unselectedItemColor: widget.unselectedItemColor,
      selectedItemColor: widget.selectedItemColor,
      fixedColor: widget.fixedColor,
      onTap: widget.onTap,
    );
  }
}