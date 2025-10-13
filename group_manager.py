# Tchat version .py (group_manager.py)
# Xavier-Bonheur TOKO-PROUST 

# ------------------------------ GROUP MANAGER -------------------------
class GroupManager:
    def __init__(self):
        self.groups = {}

    def create_group(self, group_name):
        if group_name in self.groups:
            return False
        self.groups[group_name] = []
        return True

    def join_group(self, group_name, pseudo):
        if group_name not in self.groups:
            return False 
        if pseudo not in self.groups[group_name]:
            self.groups[group_name].append(pseudo)
        return True

    def leave_group(self, group_name, pseudo):
        if group_name in self.groups and pseudo in self.groups[group_name]:
            self.groups[group_name].remove(pseudo)
            return True
        return False

    def remove_user(self, pseudo):
        for group in self.groups.values():
            if pseudo in group:
                group.remove(pseudo)

    def get_members(self, group_name):
        if group_name in self.groups:
            return self.groups[group_name]
        return []

    def get_all_groups(self):
        return list(self.groups.keys())
