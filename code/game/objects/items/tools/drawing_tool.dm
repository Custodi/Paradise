/obj/item/drawing_tool
    name = "Drawing Tool"
    var/icon/canvas = null  // Stores the drawing
    var/obj/screen/screen_object = null  // Screen object for the canvas

    New()
        ..()
        canvas = new /icon('icons/white_canvas.dmi')  // White canvas 32x32

    proc/open_canvas(mob/user)
        if(screen_object)
            close_canvas(user)
            return

        screen_object = new /obj/screen
        screen_object.icon = new /icon(canvas)  // Load saved canvas
        screen_object.owner = src
        screen_object.transform = matrix(12.5, 0, 0, 12.5, 0, 0)  // Scale to 400x400
        user.client.screen += screen_object  // Display canvas in UI

    proc/close_canvas(mob/user)
        if(screen_object)
            canvas = new /icon(screen_object.icon)  // Save the drawing
            user.client.screen -= screen_object
            del(screen_object)
            screen_object = null

    /obj/item/drawing_tool/proc/attack_self(mob/user)  // Corrected attack_self
        if(ismob(user))
            open_canvas(user)


/obj/screen
    name = "Canvas"
    icon = 'icons/white_canvas.dmi'
    screen_loc = "CENTER"
    layer = 100
    transform = matrix(12.5, 0, 0, 12.5, 0, 0)  // Scale to 400x400
    var/obj/item/drawing_tool/owner = null

    MouseDrag(location, control, params)
        if(owner)
            var/icon/brush = new /icon('icons/brush.dmi')  // Black brush
            if(istype(src.icon, /icon))  // Ensure src.icon is an icon object
                var/icon/temp = new /icon(src.icon)
                temp.Blend(brush, ICON_OVERLAY, params["rel_x"] - 200, params["rel_y"] - 200)
                src.icon = temp  // Apply the drawing update
