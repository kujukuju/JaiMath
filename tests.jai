main :: () {
    {
        ray1 := Ray3.{.{0, 0.1, -1}, normalize(.{1, 0, 0})};
        ray2 := Ray3.{.{0, -0.1, 1}, normalize(.{1, 0, -1})};

        p1, p2 := closest_point(ray1, ray2);
        print("p1, p2 % %\n", p1, p2);
    }

    // {
    //     ray := Ray2.{.{0.5, 5}, .{0, -1}};
    //     convex := Vector2.[.{1, 1}, .{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 1.5}];
    //     hit, start, end := interesct_ray_convex_polygon(ray, convex);
    //     if !equals(hit, true) || !equals(ray.p + ray.dir * start, .{0.5, 1.25}) || !equals(ray.p + ray.dir * end, .{0.5, -1}) {
    //         error("ray convex poly");
    //     }
    // }
    // {
    //     ray := Ray2.{.{2, 1.25}, .{-1, 0}};
    //     convex := Vector2.[.{1, 1}, .{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 1.5}];
    //     hit, start, end := interesct_ray_convex_polygon(ray, convex);
    //     if !equals(hit, true) || !equals(ray.p + ray.dir * start, .{0.5, 1.25}) || !equals(ray.p + ray.dir * end, .{-0.5, 1.25}) {
    //         error("ray convex poly");
    //     }
    // }
    // {
    //     ray := Ray2.{.{2, 2.25}, .{-1, 0}};
    //     convex := Vector2.[.{1, 1}, .{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 1.5}];
    //     hit, start, end := interesct_ray_convex_polygon(ray, convex);
    //     if !equals(hit, false) {
    //         error("ray convex poly");
    //     }
    // }
    // {
    //     ray := Ray2.{.{0.25, 0.25}, .{-1, 0}};
    //     convex := Vector2.[.{1, 1}, .{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 1.5}];
    //     hit, start, end := interesct_ray_convex_polygon(ray, convex);
    //     if !equals(hit, true) || !equals(ray.p + ray.dir * end, .{-1, 0.25}) {
    //         error("ray convex poly");
    //     }
    // }
    // {
    //     // above
    //     convex1 := Vector2.[.{1, 1}, .{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 1.5}];
    //     // below
    //     convex2 := Vector2.[.{1, 2}, .{1, 0}, .{-1, 0}, .{-1, 2}, .{0, 2.5}];
    //     // move above up a little
    //     exit1 := overlap(convex2, convex1, .{0, -1});
    //     if !equals(exit1, .{0, -1.5}) {
    //         error("overlap with vector 1");
    //     }
    //     // move below up a lot
    //     exit2 := overlap(convex1, convex2, .{0, -1});
    //     if !equals(exit2, .{0, -3.5}) {
    //         error("overlap with vector 2");
    //     }

    //     convex3 := Vector2.[.{2.5, 1}, .{2.5, -1}, .{0.5, -1}, .{0.5, 1}, .{1.5, 1.5}];
    //     exit3 := overlap(convex1, convex3, .{0, -1});
    //     if !equals(exit3, .{0, -2.25}) {
    //         error("overlap with vector 3");
    //     }
    // }
    // // {
    // //     concave := Vector2.[.{-2, -2}, .{0, 0}, .{-2, 2}, .{2, 2}, .{2, -2}];
    // //     convex := decompose(concave);
    // //     print("convex %\n", convex);
    // //
    // //     if !equals(convex, .[.[.{2, 2}, .{-2, 2}, .{0, 0}], .[.{0, 0}, .{-2, -2}, .{2, -2}, .{2, 2}]]) {
    // //         error("concave poly decomp");
    // //     }
    // // }
    // {
    //     inside := intersects(Triangle2.{.{-1, 1}, .{1, 1}, .{0, -1}}, .{0, 0});
    //     if !equals(inside, true) {
    //         error("inside triangle");
    //     }
    // }
    // {
    //     inside := intersects(Triangle2.{.{-1, 1}, .{1, 1}, .{0, -1}}, .{1, 0});
    //     if !equals(inside, false) {
    //         error("inside triangle");
    //     }
    // }
    // {
    //     // rotate rotates in cw direction around the vector
    //     vec := Vector3.{0, 1, 0};
    //     out := rotate(vec, .{1, 0, 0}, PI / 2.0);
    //     if !equals(out, .{0, 0, 1}) {
    //         error("vec rotate");
    //     }
    // }
    // {
    //     vec := Vector3.{0, 1, 0};
    //     out := rotate(vec, .{cast(float) SQRT2_2, cast(float) SQRT2_2, 0}, PI);
    //     if !equals(out, .{1, 0, 0}) {
    //         error("vec rotate");
    //     }
    // }
    // {
    //     vec := Vector3.{0, 0, -1};
    //     out := rotate(vec, .{cast(float) SQRT2_2, cast(float) SQRT2_2, 0}, -PI / 2.0);
    //     if !equals(out, .{cast(float) SQRT2_2, cast(float) -SQRT2_2, 0}) {
    //         error("vec rotate");
    //     }
    // }
    // {
    //     // ccw is assuming the top of your screen is -y and the bottom of your screen is +y
    //     ccw := is_ccw(Triangle2.{.{1, -1}, .{-1, -1}, .{0, 1}});
    //     if !equals(ccw, true) {
    //         error("ccw");
    //     }
    // }
    // {
    //     // hit inside directly at starting point
    //     point, hit := intersection(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 0}, .{0, 0, -1}});
    //     if !equals(hit, true) {
    //         error("sphere collision");
    //     }
    //     if !equals(point, .{1, 1, 0}) {
    //         error("sphere collision");
    //     }
    // }
    // {
    //     // hit on the surface, +z
    //     point, hit := intersection(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{0, 0, -1}});
    //     if !equals(hit, true) {
    //         error("sphere collision");
    //     }
    //     if !equals(point, .{1, 1, 3.741657}) {
    //         error("sphere collision");
    //     }
    // }
    // {
    //     hit := intersects(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{0, 0, -1}});
    //     if !equals(hit, true) {
    //         error("sphere collision");
    //     }
    // }
    // {
    //     hit := intersects(Sphere.{.{0, 0, 0}, 4.0}, Ray3.{.{1, 1, 7}, .{cast(float) SQRT2_2, 0, cast(float) -SQRT2_2}});
    //     if !equals(hit, false) {
    //         error("sphere collision");
    //     }
    // }
    // {
    //     hit := intersects(Vector2.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{0, 0});
    //     if !equals(hit, true) {
    //         error("polygon point collision");
    //     }
    // }
    // {
    //     hit := intersects(Vector2.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{1, 0});
    //     if !equals(hit, true) {
    //         error("polygon point collision");
    //     }
    // }
    // {
    //     hit := intersects(Vector2.[.{1, -1}, .{-1, -1}, .{-1, 1}, .{0, 2}, .{1, 1}], .{1.1, 0});
    //     if !equals(hit, false) {
    //         error("polygon point collision");
    //     }
    // }
    // {
    //     dist := distance(Line2.{.{0.5, 0.5}, .{1.0, 5.0}}, .{3.0, 3.0});
    //     if !equals(dist, 2.208631) {
    //         error("line point distance");
    //     }
    // }
    // {
    //     dist := distance(Line2.{.{0.5, 0.5}, .{1.0, 5.0}}, .{1.0, 7.0});
    //     if !equals(dist, 2) {
    //         error("line point distance");
    //     }
    // }
    // #if INT_MATH {
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{9, 0}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{1, 0}, .{2, 0}, .{3, 0}, .{4, 0}, .{5, 0}, .{6, 0}, .{7, 0}, .{8, 0}, .{9, 0}]) {
    //             error("get_pixels horizontal");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{0, 9}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{0, 1}, .{0, 2}, .{0, 3}, .{0, 4}, .{0, 5}, .{0, 6}, .{0, 7}, .{0, 8}, .{0, 9}]) {
    //             error("get_pixels vertical");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{0, 0}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}]) {
    //             error("get_pixels single");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(.{.{0, 0}, .{0, 0}}, false);
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}]) {
    //             error("get_pixels single exclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{9, 4}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{1, 0}, .{2, 1}, .{3, 1}, .{4, 2}, .{5, 2}, .{6, 3}, .{7, 3}, .{8, 4}, .{9, 4}]) {
    //             error("get_pixels inclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{9, 4}, .{0, 0}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{9, 4}, .{8, 4}, .{7, 3}, .{6, 3}, .{5, 2}, .{4, 2}, .{3, 1}, .{2, 1}, .{1, 0}, .{0, 0}]) {
    //             error("get_pixels backwards inclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{9, 4}}, false);
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{1, 0}, .{2, 1}, .{3, 1}, .{4, 2}, .{5, 2}, .{6, 3}, .{7, 3}, .{8, 4}]) {
    //             error("get_pixels exclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{9, 4}, .{0, 0}}, false);
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{9, 4}, .{8, 4}, .{7, 3}, .{6, 3}, .{5, 2}, .{4, 2}, .{3, 1}, .{2, 1}, .{1, 0}]) {
    //             error("get_pixels backwards exclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{4, 9}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{0, 1}, .{1, 2}, .{1, 3}, .{2, 4}, .{2, 5}, .{3, 6}, .{3, 7}, .{4, 8}, .{4, 9}]) {
    //             error("get_pixels vertical inclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{4, 9}, .{0, 0}});
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{4, 9}, .{4, 8}, .{3, 7}, .{3, 6}, .{2, 5}, .{2, 4}, .{1, 3}, .{1, 2}, .{0, 1}, .{0, 0}]) {
    //             error("get_pixels vertical backwards inclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{0, 0}, .{4, 9}}, false);
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{0, 0}, .{0, 1}, .{1, 2}, .{1, 3}, .{2, 4}, .{2, 5}, .{3, 6}, .{3, 7}, .{4, 8}]) {
    //             error("get_pixels vertical exclusive");
    //         }
    //     }
    //     {
    //         pixels: [..] Vector2i = get_pixels(Line2i.{.{4, 9}, .{0, 0}}, false);
    //         defer array_free(pixels);
    //         if !equals(pixels, Vector2i.[.{4, 9}, .{4, 8}, .{3, 7}, .{3, 6}, .{2, 5}, .{2, 4}, .{1, 3}, .{1, 2}, .{0, 1}]) {
    //             error("get_pixels vertical backwards exclusive");
    //         }
    //     }
    // }
}

equals :: (a: [..] [..] $T, b: [] [] T) -> bool {
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

#if INT_MATH {
equals :: (a: Vector2i, b: Vector2i) -> bool {
    if a.x != b.x || a.y != b.y {
        print("TEST FAILED, NOT EQUAL:\n%\n%\n", a, b);
        return false;
    }

    return true;
}
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
INT_MATH :: false;