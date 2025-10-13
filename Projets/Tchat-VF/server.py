# Tchat version .py (server.py)
# Xavier-Bonheur TOKO-PROUST 


# -------------------------------- IMPORTS -----------------------------------
import socket
import threading
from group_manager import GroupManager
from protocol import handle_client_message, welcome_user

HOST = '127.0.0.1'
PORT = 12345

clients = {}
group_manager = GroupManager()


# -------------------------------- GENERAL -------------------------------------
def client_thread(conn,addr):
    pseudo = welcome_user(conn, clients)
    try:
        while True:
            data = conn.recv(4096).decode()
            if not data:
                break
            handle_client_message(conn, data, pseudo, clients, group_manager)
    except Exception as e:
        print(f"[ERROR] {pseudo} caused an error : {e}")
    finally:
        if conn in clients:
            pseudo = clients[conn]
            group_manager.remove_user(pseudo)
            del clients[conn]
            print(f"[INFO] Logging out {pseudo} ({addr})")
        conn.close()

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        print(f"[INFO] Server listening on {HOST}:{PORT}")
        try:
            while True:
                conn, addr = s.accept()
                print(f"[INFO] {addr} Connecting")
                threading.Thread(target=client_thread, args=(conn, addr)).start()
        except KeyboardInterrupt:
            print("\n[INFO] Server shutting down...")

if __name__== "__main__":
    main()


