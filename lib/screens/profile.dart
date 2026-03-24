import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/app.dart';
import 'package:papa_capim/models/follow_relation_model.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/screens/post.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/api_post_card.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:papa_capim/widgets/user_list_item.dart';
import 'package:papa_capim/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.user,
    this.userLogin,
  });

  final UserModel? user;
  final String? userLogin;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with RouteAware {
  bool _isRouteSubscribed = false;
  int _profileLoadRequestId = 0;
  UserModel? _displayUser;
  List<UserModel> _followers = const [];
  List<UserModel> _following = const [];
  List<PostModel> _posts = const [];
  _ConnectionsTab _selectedConnectionsTab = _ConnectionsTab.followers;
  bool _isLoading = true;
  bool _isFollowingLoading = false;
  bool _hasLoadedFollowing = false;
  bool _isFollowLoading = false;
  bool _isDeletingAccount = false;
  String? _errorMessage;

  String get _targetLogin =>
      widget.userLogin ??
      widget.user?.userLogin ??
      context.read<UserProvider>().user?.userLogin ??
      '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isRouteSubscribed) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _isRouteSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_isRouteSubscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadProfile(forceRefresh: true);
  }

  Future<List<UserModel>> _loadAllUsers(
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _ProfileCache.hasFreshAllUsers) {
      return _ProfileCache.allUsers!;
    }

    final usersByLogin = <String, UserModel>{};

    for (var page = 1; page <= 100; page++) {
      final response = await ApiService.listUsers(
        page: page,
        sessionToken: token,
      );

      if (response.statusCode != 200) {
        break;
      }

      final pageUsers = UserModel.fromList(
        jsonDecode(response.body) as List<dynamic>,
      );

      if (pageUsers.isEmpty) {
        break;
      }

      var addedAnyUser = false;
      for (final user in pageUsers) {
        final login = user.userLogin.trim();
        if (login.isEmpty || usersByLogin.containsKey(login)) {
          continue;
        }

        usersByLogin[login] = user;
        addedAnyUser = true;
      }

      if (!addedAnyUser) {
        break;
      }
    }

    final users = usersByLogin.values.toList();
    _ProfileCache.storeAllUsers(users);
    return users;
  }

  Future<List<UserModel>> _resolveUsersByLogin(
    Iterable<String> logins,
    Map<String, UserModel> cachedUsers,
    String token,
  ) async {
    final seenLogins = <String>{};
    final normalizedLogins = <String>[];

    for (final login in logins) {
      final normalizedLogin = login.trim();
      if (normalizedLogin.isEmpty || !seenLogins.add(normalizedLogin)) {
        continue;
      }

      normalizedLogins.add(normalizedLogin);
    }

    final missingLogins = normalizedLogins
        .where((login) => !cachedUsers.containsKey(login))
        .toList();

    if (missingLogins.isNotEmpty) {
      final responses = await Future.wait(
        missingLogins.map((login) => ApiService.getUser(login, token)),
      );

      for (var index = 0; index < missingLogins.length; index++) {
        final response = responses[index];
        if (response.statusCode != 200) {
          continue;
        }

        final user = UserModel.fromUserJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        cachedUsers[missingLogins[index]] = user;
        _ProfileCache.storeUser(user);
      }
    }

    return normalizedLogins
        .map((login) => cachedUsers[login])
        .whereType<UserModel>()
        .toList();
  }

  Future<List<UserModel>> _loadFollowingUsers(
    String login,
    String token,
    List<UserModel> allUsers,
  ) async {
    final following = <UserModel>[];
    final users = allUsers
        .where((user) => user.userLogin.isNotEmpty && user.userLogin != login)
        .toList();

    const batchSize = 10;
    for (var start = 0; start < users.length; start += batchSize) {
      final end = (start + batchSize) > users.length
          ? users.length
          : start + batchSize;
      final batch = users.sublist(start, end);
      final followerResponses = await Future.wait(
        batch.map((user) => ApiService.listFollowers(user.userLogin, token)),
      );

      for (var index = 0; index < batch.length; index++) {
        final response = followerResponses[index];
        if (response.statusCode != 200) {
          continue;
        }

        final relations = FollowRelationModel.fromList(
          jsonDecode(response.body) as List<dynamic>,
        );

        if (relations.any((relation) => relation.followerLogin == login)) {
          following.add(batch[index]);
        }
      }
    }

    return following;
  }

  Future<void> _loadFollowingData({
    required String login,
    required String token,
    required int requestId,
    bool forceRefresh = false,
  }) async {
    final cachedFollowing = !forceRefresh
        ? _ProfileCache.followingByLogin[login]
        : null;

    if (cachedFollowing != null) {
      if (!mounted || requestId != _profileLoadRequestId) {
        return;
      }

      setState(() {
        _following = cachedFollowing;
        _hasLoadedFollowing = true;
        _isFollowingLoading = false;
      });
      return;
    }

    if (mounted && requestId == _profileLoadRequestId) {
      setState(() {
        _isFollowingLoading = true;
      });
    }

    try {
      final allUsers = await _loadAllUsers(
        token,
        forceRefresh: forceRefresh,
      );
      final following = await _loadFollowingUsers(login, token, allUsers);
      _ProfileCache.followingByLogin[login] = following;

      if (!mounted || requestId != _profileLoadRequestId) {
        return;
      }

      setState(() {
        _following = following;
        _hasLoadedFollowing = true;
        _isFollowingLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _profileLoadRequestId) {
        return;
      }

      setState(() {
        _isFollowingLoading = false;
      });
    }
  }

  Future<void> _loadProfile({
    bool forceRefresh = false,
  }) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;
    final login = _targetLogin;
    final requestId = ++_profileLoadRequestId;

    if (token == null || token.isEmpty || login.isEmpty) {
      setState(() {
        _isLoading = false;
        _isFollowingLoading = false;
        _errorMessage = 'Nao foi possivel carregar o perfil.';
      });
      return;
    }

    if (forceRefresh) {
      _ProfileCache.followingByLogin.remove(login);
    }

    final cachedFollowing = _ProfileCache.followingByLogin[login];

    setState(() {
      _isLoading = true;
      _isFollowingLoading = cachedFollowing == null;
      _hasLoadedFollowing = cachedFollowing != null;
      _errorMessage = null;
    });

    try {
      final responses = await Future.wait([
        ApiService.getUser(login, token),
        ApiService.listFollowers(login, token),
        ApiService.listUserPosts(login, token),
      ]);

      final userResponse = responses[0] as dynamic;
      final followersResponse = responses[1] as dynamic;
      final postsResponse = responses[2] as dynamic;

      if (userResponse.statusCode != 200) {
        throw Exception('Erro ao carregar usuario');
      }

      final user = UserModel.fromUserJson(
        jsonDecode(userResponse.body) as Map<String, dynamic>,
      ).copyWith(
        token: currentUser?.token,
        sessionId: currentUser?.sessionId,
        ip: currentUser?.ip,
      );
      _ProfileCache.storeUser(user);

      final usersByLogin = {
        ..._ProfileCache.usersByLogin,
        if (user.userLogin.isNotEmpty) user.userLogin: user,
      };

      final followerRelations = followersResponse.statusCode == 200
          ? FollowRelationModel.fromList(
              jsonDecode(followersResponse.body) as List<dynamic>,
            )
          : const <FollowRelationModel>[];

      final posts = postsResponse.statusCode == 200
          ? PostModel.fromList(jsonDecode(postsResponse.body) as List<dynamic>)
          : const <PostModel>[];

      final followers = await _resolveUsersByLogin(
        followerRelations.map((relation) => relation.followerLogin),
        usersByLogin,
        token,
      );

      if (!mounted || requestId != _profileLoadRequestId) return;

      setState(() {
        _displayUser = user;
        _followers = followers;
        _following = cachedFollowing ?? const [];
        _posts = posts;
        _isLoading = false;
        _isFollowingLoading = cachedFollowing == null;
        _hasLoadedFollowing = cachedFollowing != null;
      });

      if (cachedFollowing == null || forceRefresh) {
        unawaited(
          _loadFollowingData(
            login: login,
            token: token,
            requestId: requestId,
            forceRefresh: forceRefresh,
          ),
        );
      }
    } catch (_) {
      if (!mounted || requestId != _profileLoadRequestId) return;
      setState(() {
        _isLoading = false;
        _isFollowingLoading = false;
        _errorMessage = 'Nao foi possivel carregar o perfil.';
      });
    }
  }

  Future<void> _followUser() async {
    final currentUser = context.read<UserProvider>().user;
    final viewedUser = _displayUser;
    if (currentUser?.token == null || viewedUser == null) return;

    setState(() => _isFollowLoading = true);

    try {
      final response = await ApiService.follow(
        viewedUser.userLogin,
        currentUser!.token!,
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _ProfileCache.followingByLogin.remove(currentUser.userLogin);
        await _loadProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voce esta seguindo @${viewedUser.userLogin}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao seguir: ${response.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel seguir este usuario'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  Future<void> _unfollowUser() async {
    final currentUser = context.read<UserProvider>().user;
    final viewedUser = _displayUser;
    if (currentUser?.token == null || viewedUser == null) {
      return;
    }

    setState(() => _isFollowLoading = true);

    try {
      final response = await ApiService.unfollow(
        viewedUser.userLogin,
        currentUser!.token!,
        1,
      );

      if (!mounted) return;

      if (response.statusCode == 204) {
        _ProfileCache.followingByLogin.remove(currentUser.userLogin);
        await _loadProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voce deixou de seguir @${viewedUser.userLogin}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deixar de seguir: ${response.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel deixar de seguir'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  Future<void> _openReply(PostModel post) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewPostScreen(replyToPost: post),
      ),
    );

    if (created == true && mounted) {
      _loadProfile();
    }
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.pushNamed(context, AppRoutes.profileEdit);
    if (updated == true && mounted) {
      await _loadProfile(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null ||
        currentUser.token == null ||
        currentUser.token!.isEmpty ||
        currentUser.userLogin.isEmpty ||
        _isDeletingAccount) {
      return;
    }

    final confirmationController = TextEditingController();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir conta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Digite "Excluir minha conta" para confirmar a operacao.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmationController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Excluir minha conta',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  confirmationController.text.trim() == 'Excluir minha conta',
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    confirmationController.dispose();

    if (!confirmed || !mounted) return;

    setState(() => _isDeletingAccount = true);
    final userProvider = context.read<UserProvider>();

    try {
      final response = await ApiService.deleteUser(
        currentUser.userLogin,
        currentUser.token!,
      );

      if (!mounted) return;

      if (response.statusCode == 204) {
        await SecureStorageService.clearUser();
        if (!mounted) return;
        userProvider.clearUser();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir conta: ${response.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel excluir a conta'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Widget _buildUsersList(List<UserModel> users, String emptyMessage) {
    if (users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.moss.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < users.length; index++) ...[
          _ConnectionTile(user: users[index]),
          if (index < users.length - 1) const Divider(height: 12),
        ],
      ],
    );
  }

  Widget _buildConnectionsSection() {
    final showingFollowers = _selectedConnectionsTab == _ConnectionsTab.followers;
    final users = showingFollowers ? _followers : _following;
    final emptyMessage = showingFollowers
        ? 'Nenhum seguidor ainda'
        : 'Nao segue ninguem ainda';
    final shouldShowFollowingLoader =
        !showingFollowers && _isFollowingLoading && !_hasLoadedFollowing;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ConnectionsButton(
                  label: 'Seguidores',
                  selected: showingFollowers,
                  onTap: () {
                    setState(() {
                      _selectedConnectionsTab = _ConnectionsTab.followers;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ConnectionsButton(
                  label: 'Seguindo',
                  selected: !showingFollowers,
                  onTap: () {
                    setState(() {
                      _selectedConnectionsTab = _ConnectionsTab.following;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: ValueKey(_selectedConnectionsTab),
            child: shouldShowFollowingLoader
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _buildUsersList(users, emptyMessage),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    final currentUserLogin = currentUser?.userLogin ?? '';
    final displayUser = _displayUser ?? widget.user;
    final isOwnProfile = displayUser != null &&
        currentUser != null &&
        currentUser.userLogin == displayUser.userLogin;
    final isFollowing = !isOwnProfile &&
        currentUser != null &&
        _followers.any((follower) => follower.userLogin == currentUser.userLogin);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || displayUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.cream,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage ?? 'Perfil indisponivel',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _loadProfile(forceRefresh: true),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final avatarName = displayUser.userName.isNotEmpty
        ? displayUser.userName
        : displayUser.userLogin;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Meu perfil' : displayUser.userName),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
            ),
          if (isOwnProfile)
            IconButton(
              onPressed: _isDeletingAccount ? null : _deleteAccount,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir conta',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProfile(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(
                  name: avatarName,
                  color: AppColors.forest,
                  size: AvatarSize.lg,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayUser.userName.isEmpty
                            ? displayUser.userLogin
                            : displayUser.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${displayUser.userLogin}',
                        style: const TextStyle(color: AppColors.moss),
                      ),
                    ],
                  ),
                ),
                if (!isOwnProfile)
                  FilledButton(
                    onPressed: _isFollowLoading
                        ? null
                        : (isFollowing ? _unfollowUser : _followUser),
                    child: Text(
                      _isFollowLoading
                          ? '...'
                          : (isFollowing ? 'Seguindo' : 'Seguir'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    label: 'Seguidores',
                    count: _followers.length,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'Seguindo',
                    count: _following.length,
                    isLoading: _isFollowingLoading && !_hasLoadedFollowing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConnectionsSection(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Publicacoes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_posts.isEmpty)
              Text(
                'Nenhuma publicacao ainda.',
                style: TextStyle(color: AppColors.moss.withValues(alpha: 0.7)),
              )
            else
              ..._posts.map(
                (post) => ApiPostCard(
                  post: post,
                  sessionToken: currentUser?.token ?? '',
                  currentUserLogin: currentUserLogin,
                  isOwner: isOwnProfile && post.userLogin == currentUserLogin,
                  onReply: () => _openReply(post),
                  onDeleted: _loadProfile,
                ),
              ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: isOwnProfile ? const BottomTabBar() : null,
    );
  }
}

enum _ConnectionsTab {
  followers,
  following,
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    this.isLoading = false,
  });

  final String label;
  final int count;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.leaf.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.bark,
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.forest,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCache {
  static final Map<String, UserModel> usersByLogin = {};
  static final Map<String, List<UserModel>> followingByLogin = {};
  static List<UserModel>? allUsers;
  static DateTime? _allUsersFetchedAt;

  static bool get hasFreshAllUsers {
    if (allUsers == null || _allUsersFetchedAt == null) {
      return false;
    }

    return DateTime.now().difference(_allUsersFetchedAt!) <
        const Duration(minutes: 2);
  }

  static void storeAllUsers(List<UserModel> users) {
    allUsers = users;
    _allUsersFetchedAt = DateTime.now();

    for (final user in users) {
      storeUser(user);
    }
  }

  static void storeUser(UserModel user) {
    if (user.userLogin.isEmpty) {
      return;
    }

    usersByLogin[user.userLogin] = user;
  }
}

class _ConnectionsButton extends StatelessWidget {
  const _ConnectionsButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.forest : AppColors.cream,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.cream : AppColors.forest,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return UserListItem(
      user: user,
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userLogin: user.userLogin),
          ),
        );
      },
    );
  }
}
