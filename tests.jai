main :: () {
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{9, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 0], .[3, 0], .[4, 0], .[5, 0], .[6, 0], .[7, 0], .[8, 0], .[9, 0]]) {
            error("get_pixels horizontal");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0, 9}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[0, 2], .[0, 3], .[0, 4], .[0, 5], .[0, 6], .[0, 7], .[0, 8], .[0, 9]]) {
            error("get_pixels vertical");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{9, 4}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 1], .[3, 1], .[4, 2], .[5, 2], .[6, 3], .[7, 3], .[8, 4], .[9, 4]]) {
            error("get_pixels inclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{9, 4}, .{0, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[9, 4], .[8, 4], .[7, 3], .[6, 3], .[5, 2], .[4, 2], .[3, 1], .[2, 1], .[1, 0], .[0, 0]]) {
            error("get_pixels backwards inclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{9, 4}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 1], .[3, 1], .[4, 2], .[5, 2], .[6, 3], .[7, 3], .[8, 4]]) {
            error("get_pixels exclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{9, 4}, .{0, 0}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[9, 4], .[8, 4], .[7, 3], .[6, 3], .[5, 2], .[4, 2], .[3, 1], .[2, 1], .[1, 0]]) {
            error("get_pixels backwards exclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{4, 9}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[1, 2], .[1, 3], .[2, 4], .[2, 5], .[3, 6], .[3, 7], .[4, 8], .[4, 9]]) {
            error("get_pixels vertical inclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{4, 9}, .{0, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[4, 9], .[4, 8], .[3, 7], .[3, 6], .[2, 5], .[2, 4], .[1, 3], .[1, 2], .[0, 1], .[0, 0]]) {
            error("get_pixels vertical backwards inclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{4, 9}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[1, 2], .[1, 3], .[2, 4], .[2, 5], .[3, 6], .[3, 7], .[4, 8]]) {
            error("get_pixels vertical exclusive");
            return;
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{4, 9}, .{0, 0}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[4, 9], .[4, 8], .[3, 7], .[3, 6], .[2, 5], .[2, 4], .[1, 3], .[1, 2], .[0, 1]]) {
            error("get_pixels vertical backwards exclusive");
            return;
        }
    }
}

equals :: (a: [] $T, b: [] T) -> bool {
    for i: 0..a.count - 1 {
        if !equals(a[i], b[i]) {
            print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
            return false;
        }
    }

    return true;
}

equals :: (a: [2] int, b: [2] int) -> bool {
    return a[0] == b[0] && a[1] == b[1];
}

equals :: (a: Vector2, b: Vector2) -> bool {
    return a == b;
}

equals :: (a: Vector3, b: Vector3) -> bool {
    return a == b;
}

error :: inline (test: string) {
    print("TEST FAILED (line %): %\n", context.stack_trace.line_number, test);
}

#scope_file
#load "module.jai";