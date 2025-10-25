from colorama import Fore
from library import cfast
import colorama
import httpx
import json

colorama.init(autoreset=True)

with open('static/headers.json') as file:
    headers = json.load(file)

value_uid = "100034315183639"
url = 'https://www.facebook.com/bang.hanthien.58958'
response = httpx.get(url, headers=headers, follow_redirects=True)
all_node_json = cfast.extract_json_scripts(response.text)
for idx, node_json in enumerate(all_node_json):
    path_node_json = cfast.find_all_path_by_value(node_json, value_uid)
    if isinstance(path_node_json, list):
        for path_node in path_node_json:
            value_path_node = cfast.find_all_value_by_path(node_json, path_node)
            if isinstance(value_path_node, list):
                print(Fore.LIGHTYELLOW_EX + path_node, Fore.LIGHTCYAN_EX + str(value_path_node))

for idx, node_json in enumerate(all_node_json):
    node_path = cfast.find_all_key_stack(node_json, ['expectedPreloaders','variables', 'userID'])
    if node_path:
        print(Fore.LIGHTCYAN_EX + str(node_path))
    value_node_json = cfast.find_all_value_by_path(node_json, 'require.__bbox.require.expectedPreloaders.variables.selectedID')
    if isinstance(value_node_json, list):
        for value_node in value_node_json:
            node_path = cfast.find_all_key_stack(node_json, ['selectedID'])
            print(Fore.LIGHTBLUE_EX + str(node_path), Fore.LIGHTBLUE_EX + value_node)


for idx, node_json in enumerate(all_node_json):
    value_user_id = cfast.find_all_key_stack(node_json, ['variables','userID'])
    if isinstance(value_user_id, list):
        for value_user in value_user_id:
            if isinstance(value_user, str):
                print(Fore.LIGHTGREEN_EX + str(value_user))
