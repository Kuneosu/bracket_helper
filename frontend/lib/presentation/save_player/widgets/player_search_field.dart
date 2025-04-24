import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class PlayerSearchField extends StatefulWidget {
  final List<PlayerModel> players;
  final Color groupColor;
  final Function(PlayerModel) onEditPlayer;
  final Function(PlayerModel) onDeletePlayer;

  const PlayerSearchField({
    super.key,
    required this.players,
    required this.groupColor,
    required this.onEditPlayer,
    required this.onDeletePlayer,
  });

  @override
  State<PlayerSearchField> createState() => _PlayerSearchFieldState();
}

class _PlayerSearchFieldState extends State<PlayerSearchField> {
  final TextEditingController _searchController = TextEditingController();
  List<PlayerModel> _filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _filteredPlayers =
            widget.players
                .where((player) => player.name.toLowerCase().contains(query))
                .toList();
      } else {
        _filteredPlayers = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 입력 필드
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.searchPlayerByName,
              prefixIcon: Icon(Icons.search, color: widget.groupColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                      : null,
            ),
          ),
        ),

        // 검색 결과 목록
        if (_filteredPlayers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    AppStrings.searchResults.replaceAll('%d', _filteredPlayers.length.toString()),
                    style: TST.smallTextBold,
                  ),
                ),
                ..._filteredPlayers.map(
                  (player) => ListTile(
                    title: Text(player.name),
                    leading: CircleAvatar(
                      backgroundColor: widget.groupColor.withValues(alpha: 0.2),
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: widget.groupColor),
                      ),
                    ),
                    onTap: () {
                      // 선수 선택 시 작업
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: widget.groupColor,
                          ),
                          onPressed: () => widget.onEditPlayer(player),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => widget.onDeletePlayer(player),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
