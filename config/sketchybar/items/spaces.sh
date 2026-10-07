#!/bin/bash

sketchybar --add event aerospace_workspace_change

WORKSPACES="$(aerospace list-workspaces --all 2>/dev/null)"

# AeroSpace might not be ready yet when the login service starts SketchyBar.
# These are the workspaces referenced by the current AeroSpace config.
if [ -z "$WORKSPACES" ]; then
  WORKSPACES="B C E G I M P R S T V W X Y Z"
fi

for sid in $WORKSPACES; do
  # Bisherige Darstellung der geoeffneten Programme hinter dem Workspace:
  # label.font="sketchybar-app-font:Regular:16.0"
  # label.padding_right=20
  # label.y_offset=-1
  #
  # Neue Darstellung: nur der Workspace-Buchstabe, kein App-Label.
  sketchybar --add item "space.$sid" center \
             --subscribe "space.$sid" aerospace_workspace_change front_app_switched \
             --set "space.$sid" \
                   icon="$sid" \
                   icon.padding_left=8 \
                   icon.padding_right=8 \
                   label.drawing=off \
                   script="$PLUGIN_DIR/aerospace.sh $sid" \
                   click_script="aerospace workspace $sid"
done

FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
if [ -n "$FOCUSED_WORKSPACE" ]; then
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE"
fi
