class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.taskCount,
  });

  final String id;
  final String name;
  final String description;
  final int taskCount;
}