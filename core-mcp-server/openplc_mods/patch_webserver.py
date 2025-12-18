#!/usr/bin/env python3
"""
Patch OpenPLC webserver.py to add force handling.

This script modifies the monitoring() function to handle POST requests
for forcing point values.

Usage:
    python3 patch_webserver.py /path/to/webserver.py
"""
import sys
import re

def patch_webserver(filepath):
    """Patch webserver.py to add force handling."""

    with open(filepath, 'r') as f:
        content = f.read()

    # Check if already patched
    if 'FORCE_HANDLING_START' in content:
        print("webserver.py is already patched")
        return True

    # Find the monitoring function and add POST handling
    # Look for: def monitoring():
    #           if (flask_login.current_user.is_authenticated == False):

    old_pattern = r"""(@app\.route\('/monitoring', methods=\['GET', 'POST'\]\)
def monitoring\(\):
    if \(flask_login\.current_user\.is_authenticated == False\):
        return flask\.redirect\(flask\.url_for\('login'\)\)
    else:)"""

    new_code = '''@app.route('/monitoring', methods=['GET', 'POST'])
def monitoring():
    if (flask_login.current_user.is_authenticated == False):
        return flask.redirect(flask.url_for('login'))

    # FORCE_HANDLING_START - Added by CybatiWorks for ICS Security Education
    # Handle force POST requests
    if flask.request.method == 'POST':
        try:
            point_id = flask.request.form.get('point_id')
            forced_value = flask.request.form.get('forced_value')
            force_checkbox = flask.request.form.get('force_checkbox')

            if point_id is not None:
                point_id = int(point_id)
                enable_force = (force_checkbox == 'on')

                # Convert value based on type
                if point_id < len(monitor.debug_vars):
                    debug_data = monitor.debug_vars[point_id]
                    if debug_data.type == 'BOOL':
                        value = (forced_value == 'TRUE' or forced_value == '1')
                    else:
                        try:
                            value = int(forced_value)
                        except:
                            try:
                                value = float(forced_value)
                            except:
                                value = 0

                    # Apply the force
                    monitor.force_point(point_id, enable_force, value)
                    print("Force applied: point=" + str(point_id) + ", enable=" + str(enable_force) + ", value=" + str(value))
        except Exception as e:
            print("Force handling error: " + str(e))
    # FORCE_HANDLING_END

    if True:  # Was: else:'''

    # Try to find and replace the pattern
    if re.search(old_pattern, content):
        content = re.sub(old_pattern, new_code, content)
        print("Pattern matched and replaced")
    else:
        # Try simpler replacement
        old_simple = """@app.route('/monitoring', methods=['GET', 'POST'])
def monitoring():
    if (flask_login.current_user.is_authenticated == False):
        return flask.redirect(flask.url_for('login'))
    else:"""

        if old_simple in content:
            content = content.replace(old_simple, new_code)
            print("Simple pattern matched and replaced")
        else:
            print("ERROR: Could not find monitoring function pattern to patch")
            print("Looking for:")
            print(old_simple[:200])
            return False

    # Write patched file
    with open(filepath, 'w') as f:
        f.write(content)

    print(f"Successfully patched {filepath}")
    return True


def patch_point_info(filepath):
    """Patch the point-info page to show force status and pre-check the checkbox."""

    with open(filepath, 'r') as f:
        content = f.read()

    # Check if already patched
    if 'FORCE_CHECKBOX_PATCHED' in content:
        print("point-info checkbox already patched")
        return True

    # Find the force_checkbox input and make it check if forced
    # Old: <input id="force_checkbox" type="checkbox">
    # New: <input id="force_checkbox" type="checkbox" {% if forced %}checked{% endif %}>

    old_checkbox = '<input id="force_checkbox" type="checkbox">'

    # We need to add logic to check the checkbox if already forced
    # This requires modifying where the checkbox is rendered

    # Look for the line and add the check
    new_checkbox_code = '''<input id="force_checkbox" type="checkbox" ''' + "\"\"\" + ('checked' if debug_data.forced == 'Yes' else '') + \"\"\"" + '''><!-- FORCE_CHECKBOX_PATCHED -->'''

    if old_checkbox in content:
        content = content.replace(old_checkbox, new_checkbox_code)
        print("Checkbox patched to show force status")
    else:
        print("Warning: Could not find checkbox to patch")

    with open(filepath, 'w') as f:
        f.write(content)

    return True


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 patch_webserver.py <webserver.py path>")
        sys.exit(1)

    filepath = sys.argv[1]

    if not patch_webserver(filepath):
        sys.exit(1)

    # Also patch checkbox
    patch_point_info(filepath)

    print("\nPatch complete! Restart OpenPLC webserver to apply changes.")
