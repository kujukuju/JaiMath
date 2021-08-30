main :: () {
    {
        // ccw is assuming the top of your screen is -y and the bottom of your screen is +y
        ccw := is_ccw(.{.{1, -1}, .{-1, -1}, .{0, 1}});
        if !equals(ccw, true) {
            error("ccw");
        }
    }
    {
        // hit inside directly at starting point
        point, hit := intersection(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 0}, .{0, 0, -1}});
        if !equals(hit, true) {
            error("sphere collision");
        }
        if !equals(point, .{1, 1, 0}) {
            error("sphere collision");
        }
    }
    {
        // hit on the surface, +z
        point, hit := intersection(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{0, 0, -1}});
        if !equals(hit, true) {
            error("sphere collision");
        }
        if !equals(point, .{1, 1, 3.741657}) {
            error("sphere collision");
        }
    }
    {
        hit := intersects(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{0, 0, -1}});
        if !equals(hit, true) {
            error("sphere collision");
        }
    }
    {
        hit := intersects(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{SQRT2_2, 0, -SQRT2_2}});
        if !equals(hit, false) {
            error("sphere collision");
        }
    }
    {
        hit := intersects(.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{0, 0});
        if !equals(hit, true) {
            error("polygon point collision");
        }
    }
    {
        hit := intersects(.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{1, 0});
        if !equals(hit, true) {
            error("polygon point collision");
        }
    }
    {
        hit := intersects(.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{1.1, 0});
        if !equals(hit, false) {
            error("polygon point collision");
        }
    }
    {
        dist := distance(Line2.{.{0.5, 0.5}, .{1.0, 5.0}}, .{3.0, 3.0});
        if !equals(dist, 2.208631) {
            error("line point distance");
        }
    }
    {
        dist := distance(Line2.{.{0.5, 0.5}, .{1.0, 5.0}}, .{1.0, 7.0});
        if !equals(dist, 2) {
            error("line point distance");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(Line2.{.{0, 0}, .{9, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 0], .[3, 0], .[4, 0], .[5, 0], .[6, 0], .[7, 0], .[8, 0], .[9, 0]]) {
            error("get_pixels horizontal");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0, 9}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[0, 2], .[0, 3], .[0, 4], .[0, 5], .[0, 6], .[0, 7], .[0, 8], .[0, 9]]) {
            error("get_pixels vertical");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0]]) {
            error("get_pixels single");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0.1, 0.1}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0]]) {
            error("get_pixels near single");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0, 0}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0]]) {
            error("get_pixels single exclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{0.1, 0.1}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0]]) {
            error("get_pixels near single exclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{9, 4}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 1], .[3, 1], .[4, 2], .[5, 2], .[6, 3], .[7, 3], .[8, 4], .[9, 4]]) {
            error("get_pixels inclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{9, 4}, .{0, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[9, 4], .[8, 4], .[7, 3], .[6, 3], .[5, 2], .[4, 2], .[3, 1], .[2, 1], .[1, 0], .[0, 0]]) {
            error("get_pixels backwards inclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{9, 4}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[1, 0], .[2, 1], .[3, 1], .[4, 2], .[5, 2], .[6, 3], .[7, 3], .[8, 4]]) {
            error("get_pixels exclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{9, 4}, .{0, 0}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[9, 4], .[8, 4], .[7, 3], .[6, 3], .[5, 2], .[4, 2], .[3, 1], .[2, 1], .[1, 0]]) {
            error("get_pixels backwards exclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{4, 9}});
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[1, 2], .[1, 3], .[2, 4], .[2, 5], .[3, 6], .[3, 7], .[4, 8], .[4, 9]]) {
            error("get_pixels vertical inclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{4, 9}, .{0, 0}});
        defer free(*pixels);
        if !equals(pixels, .[.[4, 9], .[4, 8], .[3, 7], .[3, 6], .[2, 5], .[2, 4], .[1, 3], .[1, 2], .[0, 1], .[0, 0]]) {
            error("get_pixels vertical backwards inclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{0, 0}, .{4, 9}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[0, 0], .[0, 1], .[1, 2], .[1, 3], .[2, 4], .[2, 5], .[3, 6], .[3, 7], .[4, 8]]) {
            error("get_pixels vertical exclusive");
        }
    }
    {
        pixels: [..] [2] int = get_pixels(.{.{4, 9}, .{0, 0}}, false);
        defer free(*pixels);
        if !equals(pixels, .[.[4, 9], .[4, 8], .[3, 7], .[3, 6], .[2, 5], .[2, 4], .[1, 3], .[1, 2], .[0, 1]]) {
            error("get_pixels vertical backwards exclusive");
        }
    }
}

equals :: (a: [] $T, b: [] T) -> bool {
    if a.count != b.count {
            print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
            return false;
    }

    for i: 0..a.count - 1 {
        if !equals(a[i], b[i]) {
            print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
            return false;
        }
    }

    return true;
}

equals :: (a: Vector2, b: Vector2) -> bool {
    if length(a - b) > EPSILON {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}

equals :: (a: [2] int, b: [2] int) -> bool {
    if a[0] != b[0] || a[1] != b[1] {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}

equals :: (a: Vector3, b: Vector3) -> bool {
    if length(a - b) > EPSILON {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}

equals :: (a: float, b: float) -> bool {
    if abs(a - b) > EPSILON {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}

equals :: (a: bool, b: bool) -> bool {
    if a != b {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}

// equals_mem :: (a: $T, b: T) -> bool {
//     bytes := size_of(T);

//     a_bytes: *u8 = cast(*u8) *a;
//     b_bytes: *u8 = cast(*u8) *b;

//     for i: 0..bytes - 1 {
//         if a_bytes[i] != b_bytes[i] {
//             print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
//             return false;
//         }
//     }

//     return true;
// }

// equals :: (a: [2] int, b: [2] int) -> bool {
//     if a[0] != b[0] || a[1] != b[1] {
//         print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
//     }
//     return a[0] == b[0] && a[1] == b[1];
// }

// equals :: (a: Vector2, b: Vector2) -> bool {
//     return a == b;
// }

// equals :: (a: Vector3, b: Vector3) -> bool {
//     return a == b;
// }

error :: inline (test: string) {
    print("TEST FAILED (line %): %\n", context.stack_trace.line_number, test);
}

#scope_file
#load "module.jai";

EPSILON :: 0.000001;
SQRT2_2 :: 0.707106781;