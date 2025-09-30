import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cubit/user_cubit.dart';
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
@override
  void initState() {
    BlocProvider.of<UserCubit>(context).fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<UserCubit, UserState>(builder: (context, state) {
        if (state.status == UserStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == UserStatus.loaded &&
            (state.users == null || state.users!.isEmpty)) {
          return const Center(child: Text('No users found.'));
        } else if (state.status == UserStatus.loaded && state.users != null) {
          final users = state.users!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                key: ValueKey(user.id),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user.avatar ?? ''),
                ),
                title: Text(user.firstName),
                subtitle: Text(user.email),
              );
            },
          );
        } else if (state.status == UserStatus.error) {
          return Center(child: Text(state.error ?? 'An error occurred'));
        } else {
          return const Center(child: Text('Press the button to load users.'));
        }
      }),
    );
  }
}
