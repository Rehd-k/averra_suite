import 'package:flutter/material.dart';

class SlidingProfileDropdown extends StatefulWidget {
  const SlidingProfileDropdown({super.key});

  @override
  State<SlidingProfileDropdown> createState() => _SlidingProfileDropdownState();
}

class _SlidingProfileDropdownState extends State<SlidingProfileDropdown>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(
            -250,
            40,
          ), // Adjust for position relative to bell
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Dismiss area
                GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _controller,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).cardColor,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 350),
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                spacing: 20,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(child: Text('data')),

                                  Text(
                                    'LastName FirstName',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _controller.forward();
  }

  void _closeDropdown() async {
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Tooltip(
        message: 'Profile',
        child: InkWell(
          onTap: _toggleDropdown,

          child: const Icon(Icons.person_2_outlined, size: 12),
        ),
      ),
    );
  }
}
