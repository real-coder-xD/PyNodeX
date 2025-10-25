import json
import re

def find_key_stack(object node_json, object targets):
    cdef list stack = [(node_json, 0)]
    cdef object node, key, value, item
    cdef Py_ssize_t idx

    while stack:
        node, idx = stack.pop()

        if idx == len(targets):
            return node

        key = targets[idx]

        if isinstance(node, dict):
            if key in node:
                stack.append((node[key], idx + 1))
            for value in node.values():
                if value is not node.get(key):
                    stack.append((value, idx))
        elif isinstance(node, list):
            for item in node:
                stack.append((item, idx))

    return None

def find_all_key_stack(object node_json, object targets):
    cdef list stack = [(node_json, 0)]
    cdef object node, key, value, item
    cdef list results = []
    cdef Py_ssize_t idx

    while stack:
        node, idx = stack.pop()

        if idx == len(targets):
            results.append(node)
            continue

        key = targets[idx]

        if isinstance(node, dict):
            if key in node:
                stack.append((node[key], idx + 1))
            for value in node.values():
                if value is not node.get(key):
                    stack.append((value, idx))
        elif isinstance(node, list):
            for item in node:
                stack.append((item, idx))

    return results

def find_node_path(data, targets, bint include_index=False, long max_depth=1000):
    cdef list stack = [(data, 0, "")]
    cdef str path, new_path, key
    cdef Py_ssize_t idx, index
    cdef object node, value
    cdef set seen = set()

    while stack:
        node, idx, path = stack.pop()

        if idx > max_depth:
            continue

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if idx == len(targets):
            return path

        if isinstance(node, dict):
            key = targets[idx]
            if key in node:
                new_path = f"{path}.{key}" if path else key
                stack.append((node[key], idx + 1, new_path))
            for k, v in node.items():
                if k != key:
                    new_path = f"{path}.{k}" if path else k
                    stack.append((v, idx, new_path))
        elif isinstance(node, list):
            for index in range(len(node)):
                value = node[index]
                if include_index:
                    new_path = f"{path}[{index}]" if path else f"[{index}]"
                else:
                    new_path = path
                stack.append((value, idx, new_path))

    return None

def find_all_node_path(data, targets, bint include_index=False, long max_depth=1000):
    cdef list stack = [(data, 0, "")]
    cdef str path, new_path, key
    cdef Py_ssize_t idx, index
    cdef object node, value
    cdef list results = []
    cdef set seen = set()

    while stack:
        node, idx, path = stack.pop()

        if idx > max_depth:
            continue

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if idx == len(targets):
            results.append(path)
            continue

        key = targets[idx]

        if isinstance(node, dict):
            if key in node:
                new_path = f"{path}.{key}" if path else key
                stack.append((node[key], idx + 1, new_path))
            for k, v in node.items():
                if k != key:
                    new_path = f"{path}.{k}" if path else k
                    stack.append((v, idx, new_path))
        elif isinstance(node, list):
            for index in range(len(node)):
                value = node[index]
                if include_index:
                    new_path = f"{path}[{index}]" if path else f"[{index}]"
                else:
                    new_path = path
                stack.append((value, idx, new_path))

    return results

def find_value_by_path(object data, str path, long max_depth=1000):
    cdef list parts = re.findall(r"[^\.\[\]]+|\[\d+\]", path)
    cdef Py_ssize_t idx, index, depth
    cdef list stack = [(data, 0, 0)]
    cdef object node, value, part
    cdef set seen = set()

    while stack:
        node, idx, depth = stack.pop()
        if depth > max_depth:
            continue

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if idx == len(parts):
            return node

        part = parts[idx]

        if part.startswith("[") and part.endswith("]"):
            try:
                index = int(part[1:-1])
            except ValueError:
                continue
            if isinstance(node, list) and 0 <= index < len(node):
                stack.append((node[index], idx + 1, depth + 1))
            continue

        if isinstance(node, dict):
            if part in node:
                stack.append((node[part], idx + 1, depth + 1))
        elif isinstance(node, list):
            for index in range(len(node)):
                stack.append((node[index], idx, depth + 1))

    return None

def find_all_value_by_path(object data, str path, long max_depth=1000):
    cdef list parts = re.findall(r"[^\.\[\]]+|\[\d+\]", path)
    cdef Py_ssize_t idx, index, depth
    cdef list stack = [(data, 0, 0)]
    cdef object node, value, part
    cdef list results = []
    cdef set seen = set()

    while stack:
        node, idx, depth = stack.pop()
        if depth > max_depth:
            continue

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if idx == len(parts):
            results.append(node)
            continue

        part = parts[idx]

        if part.startswith("[") and part.endswith("]"):
            try:
                index = int(part[1:-1])
            except ValueError:
                continue
            if isinstance(node, list) and 0 <= index < len(node):
                stack.append((node[index], idx + 1, depth + 1))
            continue

        if isinstance(node, dict):
            if part in node:
                stack.append((node[part], idx + 1, depth + 1))
        elif isinstance(node, list):
            for index in range(len(node)):
                stack.append((node[index], idx, depth + 1))

    return results

def find_path_by_value(object data, object target, bint include_index=False, long max_depth=1000):
    cdef list stack = [(data, "", 0)]
    cdef object node, value, key
    cdef Py_ssize_t index, depth
    cdef str path, new_path
    cdef set seen = set()

    while stack:
        node, path, depth = stack.pop()
        if depth > max_depth:
            continue

        if node == target:
            return path.lstrip(".")

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if isinstance(node, dict):
            for key, value in node.items():
                new_path = f"{path}.{key}" if path else key
                stack.append((value, new_path, depth + 1))

        elif isinstance(node, list):
            for index in range(len(node)):
                value = node[index]
                new_path = f"{path}[{index}]" if include_index else path
                stack.append((value, new_path, depth + 1))

    return None

def find_all_path_by_value(object data, object target, bint include_index=False, long max_depth=1000):
    cdef list stack = [(data, "", 0)]
    cdef Py_ssize_t index, depth
    cdef object node, value, key
    cdef str path, new_path
    cdef list results = []
    cdef set seen = set()

    while stack:
        node, path, depth = stack.pop()
        if depth > max_depth:
            continue

        if node == target:
            results.append(path.lstrip("."))

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if isinstance(node, dict):
            for key, value in node.items():
                new_path = f"{path}.{key}" if path else key
                stack.append((value, new_path, depth + 1))

        elif isinstance(node, list):
            for index in range(len(node)):
                value = node[index]
                new_path = f"{path}[{index}]" if include_index else path
                stack.append((value, new_path, depth + 1))

    return results

def flatten_json(object data, bint include_index=True, long max_depth=1000):
    cdef Py_ssize_t index, depth, size
    cdef list stack = [(data, "", 0)]
    cdef str path, new_path, key
    cdef object node, value
    cdef dict flat_dict = {}
    cdef set seen = set()

    while stack:
        node, path, depth = stack.pop()

        if depth > max_depth:
            continue

        if isinstance(node, (dict, list)):
            node_id = id(node)
            if node_id in seen:
                continue
            seen.add(node_id)

        if isinstance(node, dict):
            for key, value in node.items():
                new_path = f"{path}.{key}" if path else key
                stack.append((value, new_path, depth + 1))

        elif isinstance(node, list):
            size = len(node)
            for index in range(size):
                value = node[index]
                if include_index:
                    new_path = f"{path}[{index}]" if path else f"[{index}]"
                else:
                    new_path = path
                stack.append((value, new_path, depth + 1))

        else:
            flat_dict[path] = node

    return flat_dict

def extract_json_scripts(str response):
    cdef list results = []
    cdef list scripts
    try:
        scripts = re.findall(
            r'<script[^>]*type="application/json"[^>]*>(.*?)</script>',
            string=response, flags=re.DOTALL
        )
        for script in scripts:
            try:
                results.append(json.loads(script))
            except json.JSONDecodeError:
                continue
    except Exception:
        pass
    return results
