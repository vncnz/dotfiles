from ignis.services.applications import ApplicationsService

applications = ApplicationsService.get_default()
for i in applications.apps:
    print(i.name, i.icon, i.id, i.executable)