import ast
import base64
import random
import string


class Obfuscator(ast.NodeTransformer):
    def __init__(self):
        self.name_map = {}
        self.used_names = set()
        self.excluded_names = {'print', 'range', 'int', 'str', 'len', 'main', 'base64', 'b64decode', 'decode'}

    def _generate_random_name(self, original_name):
        if original_name in self.name_map:
            return self.name_map[original_name]

        if (original_name.startswith('__') or
                original_name in self.excluded_names):
            return original_name

        new_name = 'O0oO' + ''.join(random.choices(string.ascii_letters, k=8))
        while new_name in self.used_names:
            new_name = 'O0oO' + ''.join(random.choices(string.ascii_letters, k=8))

        self.used_names.add(new_name)
        self.name_map[original_name] = new_name
        return new_name

    def visit_FunctionDef(self, node):
        if not node.name.startswith('__') and node.name != 'main':
            node.name = self._generate_random_name(node.name)
        for arg in node.args.args:
            arg.arg = self._generate_random_name(arg.arg)
        return self.generic_visit(node)

    def visit_Name(self, node):
        if isinstance(node.ctx, (ast.Load, ast.Store)):
            if node.id not in self.excluded_names:
                node.id = self._generate_random_name(node.id)
        return node

    def visit_JoinedStr(self, node):
        template = ""
        format_args = []
        for value in node.values:
            if isinstance(value, ast.Constant):
                template += str(value.value).replace("{", "{{").replace("}", "}}")
            elif isinstance(value, ast.FormattedValue):
                template += "{}"
                format_args.append(self.visit(value.value))

        encoded_template = base64.b64encode(template.encode()).decode()
        return ast.Call(
            func=ast.Attribute(
                value=ast.Call(
                    func=ast.Attribute(
                        value=ast.Call(
                            func=ast.Attribute(
                                value=ast.Name(id='base64', ctx=ast.Load()),
                                attr='b64decode',
                                ctx=ast.Load()
                            ),
                            args=[ast.Constant(value=encoded_template)],
                            keywords=[]
                        ),
                        attr='decode',
                        ctx=ast.Load()
                    ),
                    args=[],
                    keywords=[]
                ),
                attr='format',
                ctx=ast.Load()
            ),
            args=format_args,
            keywords=[]
        )

    def visit_Constant(self, node):
        if isinstance(node.value, str) and not node.value.startswith('__'):
            encoded = base64.b64encode(node.value.encode()).decode()
            return ast.Call(
                func=ast.Attribute(
                    value=ast.Call(
                        func=ast.Attribute(
                            value=ast.Name(id='base64', ctx=ast.Load()),
                            attr='b64decode',
                            ctx=ast.Load()
                        ),
                        args=[ast.Constant(value=encoded)],
                        keywords=[]
                    ),
                    attr='decode',
                    ctx=ast.Load()
                ),
                args=[],
                keywords=[]
            )
        return node


def obfuscate_file(input_path, output_path):
    with open(input_path, 'r') as f:
        source = f.read()

    tree = ast.parse(source)
    obfuscator = Obfuscator()
    obfuscated_tree = obfuscator.visit(tree)

    import_node = ast.Import(names=[ast.alias(name='base64')])
    obfuscated_tree.body.insert(0, import_node)

    ast.fix_missing_locations(obfuscated_tree)

    obfuscated_code = ast.unparse(obfuscated_tree)

    with open(output_path, 'w') as f:
        f.write("# -*- coding: utf-8 -*-\n")
        f.write(obfuscated_code)


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        obfuscate_file('secret_logic.py', 'obfuscated_logic.py')
        print("Obfuscated secret_logic.py -> obfuscated_logic.py")
    else:
        obfuscate_file(sys.argv[1], sys.argv[2])
        print(f"Obfuscated {sys.argv[1]} -> {sys.argv[2]}")
