# Tchat version .py (client.py)
# Xavier-Bonheur TOKO-PROUST 


# -------------------------------- IMPORTS -----------------------------------
import socket
import threading
import sys

HOST = '172.21.10.179'
PORT = 1312

# -------------------------------- GENERAL -------------------------------------
def receive_messages(sock):
    while True:
        try:
            data = sock.recv(1024)
            if not data:
                print("Disconnected from the server.")
                break
            print(data.decode().strip())
        except (ConnectionResetError, OSError):
            break
        except:
            print("Reception error.")
            break

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.connect((HOST, PORT))
        except:
            print("Unable to reach the server.")
            sys.exit()

        threading.Thread(target=receive_messages, args=(s,), daemon=True).start()

        while True:
            try:
                msg = input()
                if msg == "":
                    continue

                if msg.startswith("SPEAK ") or msg.startswith("MSGPV "):
                    message = msg + "\n"
                    print("Enter message (line by line). End with a point ('.') on a single line.")
                    while True:
                        line = input()
                        message += line + "\n"
                        if line.strip() == ".":
                            break
                    s.sendall(message.encode())
                else:
                    s.sendall((msg + "\n").encode())
            except KeyboardInterrupt:
                print("\nCustomer logout...")
                break
            except Exception as e:
                print("Erreur :", e)
                break


if __name__ == "__main__":
    main()


