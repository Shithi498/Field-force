import 'package:field_force_2/view/project_details_page.dart';
import 'package:field_force_2/view/task_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/project_provider.dart';
import '../provider/task_provider.dart';
import '../model/project_model.dart';
import '../model/task_model.dart';

class ProjectsTasksPage extends StatefulWidget {
  const ProjectsTasksPage({super.key});

  @override
  State<ProjectsTasksPage> createState() => _ProjectsTasksPageState();
}

class _ProjectsTasksPageState extends State<ProjectsTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    // LOAD BOTH LISTS AUTOMATICALLY
    Future.microtask(() {
      context.read<ProjectProvider>().loadProjects();
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects & Tasks"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Projects"),
            Tab(text: "Tasks"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tab,
        children: [
          _ProjectsTab(),
          _TasksTab(),
        ],
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProjectProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.error != null) return Center(child: Text(prov.error!));
    if (prov.projects.isEmpty) return const Center(child: Text("No Projects Found"));

    return RefreshIndicator(
      onRefresh: prov.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: prov.projects.length,
        itemBuilder: (_, i) => _ProjectTile(prov.projects[i]),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project p;
  const _ProjectTile(this.p);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manager: ${p.managerName}", style: const TextStyle(fontSize: 14)),
            Text("Client: ${p.customerName}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            _progressBar(p.progress),
          ],
        ),
        trailing: Text("${p.progress.toStringAsFixed(0)}%"),
        onTap: () {

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailsPage(project: p),
              ),
            );


        },
      ),
    );
  }

  Widget _progressBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress / 100,
        minHeight: 6,
        backgroundColor: Colors.grey.shade300,
        color: Colors.green,
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TaskProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.error != null) return Center(child: Text(prov.error!));
    if (prov.tasks.isEmpty) return const Center(child: Text("No Tasks Found"));

    return RefreshIndicator(
      onRefresh: prov.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: prov.tasks.length,
        itemBuilder: (_, i) => _TaskTile(prov.tasks[i]),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task t;
  const _TaskTile(this.t);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(t.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${t.status.toUpperCase()} • ${t.projectName}", style: TextStyle(color: Colors.blue.shade700)),
            Text("Deadline: ${t.deadline ?? '---'}", style: const TextStyle(fontSize: 14)),
          ],
        ),
        trailing: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.orange.shade100,
          child: Text(t.priority.toString(), style: const TextStyle(fontSize: 14)),
        ),
        onTap: () {

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskDetailsPage(task: t),
              ),
            );


        },
      ),
    );
  }
}


