/obj/item/drawing_tool
    name = "drawing_tool"
    desc = "Test item"
    icon = 'icons/obj/tools.dmi'
    icon_state = "drawing_tool"
    var/icon/canvas = null  // Stores the drawing (initially 32x32 white)
    var/obj/screen/screen_object = null  // Screen object for the canvas

    New()
        ..()
        // Create a new icon from the white canvas file (should be 32x32)
        canvas = new /icon('icons/test/white_canvas.dmi')

    proc/open_canvas(mob/user)
        if(screen_object)
            close_canvas(user)
            return

        screen_object = new /obj/screen
        // Create a new icon based on the saved canvas
        screen_object.icon = new /icon(canvas)
        screen_object.owner = src
        // Set the screen location to center (this value determines placement on the client)
        screen_object.screen_loc = "CENTER"
        // Scale the 32x32 canvas to 400x400 (32 * 12.5 = 400)
        screen_object.transform = matrix(12.5, 0, 0, 12.5, 0, 0)
        // Add the screen object to the client's screen
        user.client.screen += screen_object

    proc/close_canvas(mob/user)
        if(screen_object)
            // Save the current drawing by creating a new icon from the screen object
            canvas = new /icon(screen_object.icon)
            user.client.screen -= screen_object
            qdel(screen_object)
            screen_object = null

    /obj/item/drawing_tool/attack_self__legacy__attackchain(mob/user)
        if(ismob(user))
            open_canvas(user)


/obj/screen
    name = "Canvas"
    icon = 'icons/test/white_canvas.dmi'
    icon_state = "Canvas"
    // Set screen location to center so the canvas appears at the center of the screen
    screen_loc = "CENTER"
    layer = 100
    // Scale the 32x32 canvas to 400x400
    transform = matrix(12.5, 0, 0, 12.5, 0, 0)
    var/obj/item/drawing_tool/owner = null

    MouseDown(location, control, params)
        if(owner)
            // Create a new icon for the brush (black brush file, e.g. 3x3)
            var/icon/brush = new /icon('icons/brush.dmi')
            if(istype(src.icon, /icon))
                var/icon/temp = new /icon(src.icon)
                // Adjust coordinates: params["rel_x"] and params["rel_y"] are relative to the canvas,
                // subtract half of the scaled canvas (400/2 = 200) to center the brush stamp.
                temp.Blend(brush, ICON_OVERLAY, params["rel_x"] - 200, params["rel_y"] - 200)
                src.icon = temp  // Update the canvas icon with the new drawing
