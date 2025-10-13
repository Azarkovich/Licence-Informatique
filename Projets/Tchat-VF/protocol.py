# Tchat version .py (protocol.py)
# Xavier-Bonheur TOKO-PROUST 


# -------------------------------- IMPORTS -----------------------------------
import re
import time 

VALID_NAME_REGEX = re.compile(r'^[a-zA-Z0-9_-]{1,16}$')


# -------------------------------- GENERAL -------------------------------------
def send(conn, msg):
    conn.sendall((msg+ '\n').encode())

def welcome_user(conn, clients):
    send(conn, "TCHAT 1")
    while True:
        try:
            send(conn, "*")
            data = conn.recv(1024)
            if not data:
                raise ConnectionResetError
            data = data.decode().strip()
        except:
                raise ConnectionResetError
        
        if not data.startswith("LOGIN "):
                send(conn, "ERROR 01")
                continue
        pseudo = data[11:]
        if not VALID_NAME_REGEX.match(pseudo):
            send(conn, "ERROR 20")
        elif pseudo in clients.values():
            send(conn, "ERROR 23")
        else:
            clients[conn] = pseudo
            send(conn, "OKAY!")
            return pseudo
        

# ----------------------------- COMMANDS ----------------------------------------
def handle_client_message(conn, msg, pseudo, clients, group_manager):
    now = int(time.time()) # timestamp pour marquer les événements 
    lines = msg.splitlines()
    if not lines:
        send(conn, "ERROR 10")
        return
    
    cmd = lines[0].strip()

    #CREATE
    if cmd.startswith("CREAT "):
        group = cmd[11:]
        if not VALID_NAME_REGEX.match(group):
            send(conn, "ERROR 30")
        elif group in group_manager.groups:
            send(conn, "ERROR 33")
        else: 
            group_manager.create_group(group)
            send(conn, "OKAY!")

    #ENTER
    elif cmd.startswith("ENTER "):
        group = cmd[11:]
        if group not in group_manager.groups:
            send(conn, "ERROR 31")
        elif pseudo in group_manager.get_members(group):
            send(conn, "ERROR 35")
        else:
            group_manager.join_group(group, pseudo)
            send(conn, "OKaY!")

            for client_conn, client_pseudo in clients.items():
                if client_pseudo in group_manager.get_members(group) and client_pseudo != pseudo:
                    send(client_conn, f"ENTER {group} {pseudo} {now}")

    #LEAVE 
    elif cmd.startswith("LEAVE "):
        group = cmd[11:]
        if group not in group_manager.groups:
            send(conn, "ERROR 31")
        elif pseudo not in group_manager.get_members(group):
            send(conn, "srv : ERROR 34")
        else:
            group_manager.leave_group(group, pseudo)
            send(conn, "OKaY!")
            for client_conn, client_pseudo, in clients.items():
                if client_pseudo in group_manager.get_members(group):
                    send(client_conn, f"LEAVE {group} {pseudo} {now}")

    #LSMEM
    elif cmd.startswith("LSMEM "):
        group = cmd[11:]
        if group not in group_manager.groups:
            send(conn, "ERROR 31")
        elif pseudo not in group_manager.get_members(group):
            send(conn, "srv : ERROR 34")
        else:
            members = group_manager.get_members(group)
            send(conn, f"LSMEM {group} {len(members)}")
            for member in members:
                send(conn, f"{member}")

    #SPEAK
    elif cmd.startswith("SPEAK "):
        group = cmd[11:]
        if group not in group_manager.groups:
            send(conn, "ERROR 31")
        elif pseudo not in group_manager.get_members(group):
            send(conn, "ERROR 34")
        else:
            message_lines = lines[1:]
            if not message_lines or message_lines == ['.']:
                send(conn, "ERROR 10")
                return
            for client_conn, client_pseudo in clients.items():
                if client_pseudo in group_manager.get_members(group):
                    send(client_conn, f"SPEAK {pseudo} {group} {now}")
                    for line in message_lines:
                        if line.strip():
                            send(client_conn, f"{line}")

    #MSGPRV
    elif cmd.startswith("MSGPV "):
        target = cmd[11:]
        if target not in clients.values():
            send(conn, "ERROR 21")
            return
        message_lines = lines[1:]
        if not message_lines or message_lines == ['.']:
            send(conn, "ERROR 10")
            return
        for client_conn, client_pseudo in clients.items():
            if client_pseudo == target:
                send(client_conn, f"MSGPV {pseudo} {now}")
                for line in message_lines:
                    send(client_conn, f"{line}")
                break

    else: 
        send(conn, "ERROR 11")
 

    

    

