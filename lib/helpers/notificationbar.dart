import 'package:flutter/material.dart';

class SlidingNotificationDropdown extends StatefulWidget {
  const SlidingNotificationDropdown({super.key});

  @override
  State<SlidingNotificationDropdown> createState() =>
      _SlidingNotificationDropdownState();
}

class _SlidingNotificationDropdownState
    extends State<SlidingNotificationDropdown>
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
                          child: ListView(
                            padding: const EdgeInsets.all(2),
                            shrinkWrap: true,
                            children: const [
                              ListTile(
                                leading: Icon(
                                  Icons.horizontal_distribute_outlined,
                                  size: 12,
                                ),
                                title: Text(
                                  'New order received',
                                  style: TextStyle(fontSize: 10),
                                ),
                                subtitle: Text(
                                  '2 mins ago',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.payment),
                                title: Text('Payment processed'),
                                subtitle: Text('10 mins ago'),
                              ),
                              ListTile(
                                leading: Icon(Icons.system_update),
                                title: Text('System update available'),
                                subtitle: Text('1 hr ago'),
                              ),
                              ListTile(
                                leading: Icon(Icons.check_circle),
                                title: Text('Task completed successfully'),
                                subtitle: Text('Yesterday'),
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
        message: 'Notifications',
        child: InkWell(
          onTap: _toggleDropdown,

          child: const Icon(Icons.notifications, size: 12),
        ),
      ),
    );
  }
}
