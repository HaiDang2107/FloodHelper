import 'package:flutter/material.dart';

class BaseCharityScreen extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  const BaseCharityScreen({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.tabs,
    required this.tabViews,
    this.initialTabIndex = 0,
    this.onTabChanged,
  });

  @override
  State<BaseCharityScreen> createState() => _BaseCharityScreenState();
}

class _BaseCharityScreenState extends State<BaseCharityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabChanged?.call(_tabController.index);
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    widget.onTabChanged?.call(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ScrollingTitle(
          text: widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        leading: widget.leading,
        actions: widget.actions,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0F62FE),
          indicatorWeight: 2,
          tabs: widget.tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabViews,
      ),
    );
  }
}

class ScrollingTitle extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollingTitle({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ScrollingTitle> createState() => _ScrollingTitleState();
}

class _ScrollingTitleState extends State<ScrollingTitle> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (mounted) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) break;

        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 2),
          curve: Curves.linear,
        );
        if (!mounted) break;

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) break;

        await _scrollController.animateTo(
          0,
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
