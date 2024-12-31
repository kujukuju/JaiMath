// page numbers come from "Real Time Collision Detection by Christer Ericson"

#module_parameters () (PRODUCTION := false);

Frustum :: struct {
    point: Vector3;
    // x,y,z is the normal
    // w is the d value
    normals: [5] Vector4;
}

Sphere :: struct {
    center: Vector3;
    radius: float;
}

create_sphere :: (center: Vector3, radius: float) -> Sphere {
    return Sphere.{center, radius};
}

create_sphere :: (p1: Vector3) -> Sphere {
    return Sphere.{
        p1,
        0.0,
    };
}

create_sphere :: (p1: Vector3, p2: Vector3) -> Sphere {
    return Sphere.{
        p1 / 2.0 + p1 / 2.0,
        distance(p1, p2) / 2.0,
    };
}

create_sphere :: (p1: Vector3, p2: Vector3, p3: Vector3) -> Sphere, bool {
    n := cross(p3 - p1, p2 - p1);
    if length_squared(n) < EPSILON {
        return .{}, false;
    }
    n = normalize(n);
    p12_center := p1 / 2.0 + p2 / 2.0;
    p23_center := p2 / 2.0 + p3 / 2.0;
    p31_center := p3 / 2.0 + p1 / 2.0;
    p12_ortho := normalize(cross(p2 - p1, n));
    p23_ortho := normalize(cross(p3 - p2, n));
    p31_ortho := normalize(cross(p1 - p3, n));

    p12_ray := Ray3.{p12_center, p12_ortho};
    p23_ray := Ray3.{p23_center, p23_ortho};

    center := nearest_point(p12_ray, p23_ray);
    radius := sqrt(max(distance_squared(p1, center), distance_squared(p2, center), distance_squared(p3, center)));

    return Sphere.{center, radius}, true;
}

create_sphere :: (p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> Sphere, bool {
    t1 := -(p1.x * p1.x + p1.y * p1.y + p1.z * p1.z);
    t2 := -(p2.x * p2.x + p2.y * p2.y + p2.z * p2.z);
    t3 := -(p3.x * p3.x + p3.y * p3.y + p3.z * p3.z);
    t4 := -(p4.x * p4.x + p4.y * p4.y + p4.z * p4.z);

    d_mat := Matrix4.{
        t1, p1.y, p1.z, 1,
        t2, p2.y, p2.z, 1,
        t3, p3.y, p3.z, 1,
        t4, p4.y, p4.z, 1,
    };
    e_mat := Matrix4.{
        p1.x, t1, p1.z, 1,
        p2.x, t2, p2.z, 1,
        p3.x, t3, p3.z, 1,
        p4.x, t4, p4.z, 1,
    };
    f_mat := Matrix4.{
        p1.x, p1.y, t1, 1,
        p2.x, p2.y, t2, 1,
        p3.x, p3.y, t3, 1,
        p4.x, p4.y, t4, 1,
    };
    g_mat := Matrix4.{
        p1.x, p1.y, p1.z, t1,
        p2.x, p2.y, p2.z, t2,
        p3.x, p3.y, p3.z, t3,
        p4.x, p4.y, p4.z, t4,
    };
    t_mat := Matrix4.{
        p1.x, p1.y, p1.z, 1,
        p2.x, p2.y, p2.z, 1,
        p3.x, p3.y, p3.z, 1,
        p4.x, p4.y, p4.z, 1,
    };
    t_det := determinant(t_mat);
    if abs(t_det) < EPSILON {
        return .{}, false;
    }
    d_det := determinant(d_mat) / t_det;
    e_det := determinant(e_mat) / t_det;
    f_det := determinant(f_mat) / t_det;
    g_det := determinant(g_mat) / t_det;

    center := Vector3.{-d_det / 2, -e_det / 2, -f_det / 2};
    radius := 0.5 * sqrt(d_det * d_det + e_det * e_det + f_det * f_det - 4 * g_det);

    return Sphere.{center, radius}, true;
}

#run {

};

AABB2 :: struct {
    lower: Vector2;
    upper: Vector2;
}

create_aabb2 :: (lower: Vector2, upper: Vector2) -> AABB2 {
    aabb: AABB2 = ---;
    aabb.lower = lower;
    aabb.upper = upper;
    return aabb;
}

AABB3 :: struct {
    lower: Vector3;
    upper: Vector3;
}

create_aabb3 :: (lower: Vector3, upper: Vector3) -> AABB3 {
    aabb: AABB3 = ---;
    aabb.lower = lower;
    aabb.upper = upper;
    return aabb;
}

Plane3_64 :: union {
    struct {
        a, b, c, d : float64;
    }
    
    n: Vector3_64;
}

create_plane3 :: (p: Vector3, n: Vector3) -> Plane3 {
    result: Plane3 = ---;
    result.a = n.x;
    result.b = n.y;
    result.c = n.z;
    result.d = dot(n, p);

    return result;
}

create_plane3_64 :: (p: Vector3_64, n: Vector3_64) -> Plane3_64 {
    result: Plane3_64 = ---;
    result.a = n.x;
    result.b = n.y;
    result.c = n.z;
    result.d = dot(n, p);

    return result;
}

Cylinder :: struct {
    // p is the center of one end
    // q is the center of the other end
    // r is radius
    p: Vector3;
    q: Vector3;
    r: float;
}

Circle3 :: struct {
    p: Vector3;
    n: Vector3;
    r: float;
}

Triangle2 :: struct {
    a: Vector2;
    b: Vector2;
    c: Vector2;
}

Triangle3 :: struct {
    a: Vector3;
    b: Vector3;
    c: Vector3;

#place a;
    component: [3] Vector3 = ---;
}

create_triangle3 :: (a: Vector3, b: Vector3, c: Vector3) -> Triangle3 {
    return .{a, b, c};
}

Ray2 :: struct {
    p: Vector2;
    dir: Vector2;
}

create_ray2 :: (p: Vector2, dir: Vector2) -> Ray2 {
    ray: Ray2 = ---;
    ray.p = p;
    ray.dir = dir;
    return ray;
}

Ray3 :: struct {
    p: Vector3;
    dir: Vector3;
}

create_ray3 :: (p: Vector3, dir: Vector3) -> Ray3 {
    ray: Ray3 = ---;
    ray.p = p;
    ray.dir = dir;
    return ray;
}

Line2 :: struct {
    p1: Vector2;
    p2: Vector2;
}

Line3 :: struct {
    p1: Vector3;
    p2: Vector3;
}

Vector2_64 :: struct {
    x, y: float64;

#place x;
    component: [2] float64 = ---;
}

Vector3_64 :: struct {
    x, y, z: float64;

#place x;
    xy: Vector2_64 = ---;
#place y;
    yz: Vector2_64 = ---;

#place x;
    component: [3] float64 = ---;
}

Vector4_64 :: struct {
    x, y, z, w: float64;

#place x;
    xy: Vector2_64 = ---;
#place y;
    yz: Vector2_64 = ---;
#place z;
    zw: Vector2_64 = ---;
#place x;
    xyz: Vector3_64 = ---;
#place y;
    yzw: Vector3_64 = ---;
#place x;
    component: [4] float64 = ---;
}

Matrix3Identity :: Matrix3.{
    1, 0, 0,
    0, 1, 0,
    0, 0, 1,
};

Matrix4Identity :: Matrix4.{
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1,
};

// concave polygon stuff
is_ccw :: (polygon: [] Vector2) -> bool {
    if polygon.count < 3 {
        return true;
    }

    size := polygon.count;
    area := 0.0;
    for i: 0..size - 1 {
        // get the current point and the next point
        p1 := polygon[i];
        p2 := polygon[ifx i + 1 == size then 0 else i + 1];
        // add the signed area
        area += cross(p2, p1);
    }
    // return the area
    return area < 0;
}

intersects_concave :: (polygon: [] Vector2, point: Vector2) -> bool {
    j := polygon.count - 1;
    odd_nodes := false;

    for i: 0..polygon.count - 1 {
        cond := polygon[i].y < point.y && polygon[j].y >= point.y || polygon[j].y < point.y && polygon[i].y >= point.y;
        cond = cond && (polygon[i].x <= point.x || polygon[j].x <= point.x);
        if cond {
            if polygon[i].x + (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x {
                odd_nodes = !odd_nodes;
            }
        }

        j = i;
    }

    return odd_nodes;
}

nearest_point_concave :: (polygon: [] Vector2, point: Vector2) -> Vector2 {
    // this method assumes the point is inside the polygon
    nearest_distance_squared := FLOAT32_MAX;
    nearest_distance_point: Vector2;

    for i: 0..polygon.count - 1 {
        p1 := polygon[i];
        p2 := polygon[(i + 1) % polygon.count];

        line: Line2 = ---;
        line.p1 = p1;
        line.p2 = p2;

        nearest := nearest_point(line, point);
        d2 := distance_squared(nearest, point);
        if d2 < nearest_distance_squared {
            nearest_distance_squared = d2;
            nearest_distance_point = nearest;
        }
    }

    return nearest_distance_point;
}

decompose :: (polygon: [] Vector2) -> [..][..] Vector2 {
    polygons: [..][..] Vector2;

    if polygon.count < 4 {
        points: [..] Vector2;
        for p: polygon {
            array_add(*points, p);
        }
        array_add(*polygons, points);
        return polygons;
    }

    if !is_ccw(polygon) {
        points: [..] Vector2;
        for p: polygon {
            array_add(*points, p);
        }
        array_add(*polygons, points);
        return polygons;
    } else {
        decompose(polygon, *polygons);
    }

    return polygons;
}

decompose :: (polygon: [] Vector2, polygons: *[..][..] Vector2) {
    add_all :: (list: *[..] Vector2, new: [] Vector2) {
        for entry: new {
            array_add(list, entry);
        }
    }

    sublist :: (list: [] Vector2, start: int, end: int) -> [] Vector2 {
       view: [] Vector2;
       view = list;
       view.data += start;
       view.count = end - start;

       return view;
    }

    right :: (a: Vector2, b: Vector2, p: Vector2) -> bool {
        return (b.x - a.x) * (p.y - a.y) - (p.x - a.x) * (b.y - a.y) > 0;
    }

    is_reflex :: (p0: Vector2, p: Vector2, p1: Vector2) -> bool {
		// if the point p is to the right of the line p0-p1 then
		// the point is a reflex vertex
		return right(p1, p0, p);
    }

    get_intersection :: (a1: Vector2, a2: Vector2, b1: Vector2, b2: Vector2, p: *Vector2) -> bool {
        s1 := a1 - a2;
		s2 := b1 - b2;
		
		// compute the cross product (the determinant if we used matrix solving techniques)
		det := cross(s2, s1);
		
		// make sure the matrix isn't singular (the lines could be parallel)
		if abs(det) <= EPSILON {
			// return false since there is no way that the segments could be intersecting
			return false;
		} else {
			// pre-divide the determinant
			det = 1.0 / det;
			
			// compute t2
			t2 := det * (cross(s1, a1) - cross(s1, b1));
			
			// compute the intersection point
			// P = B1(1.0 - t2) + B2(t2)
			p.x = b1.x * (1.0 - t2) + b2.x * t2;
			p.y = b1.y * (1.0 - t2) + b2.y * t2;
			
			// return that they intersect
			return true;
		}
    }

    left :: (a: Vector2, b: Vector2, p: Vector2) -> bool {
        return (b.x - a.x) * (p.y - a.y) - (p.x - a.x) * (b.y - a.y) < 0;
    }

    left_on :: (a: Vector2, b: Vector2, p: Vector2) -> bool {
        return (b.x - a.x) * (p.y - a.y) - (p.x - a.x) * (b.y - a.y) <= 0;
    }

    right_on :: (a: Vector2, b: Vector2, p: Vector2) -> bool {
        return (b.x - a.x) * (p.y - a.y) - (p.x - a.x) * (b.y - a.y) >= 0;
    }

    get_segment_intersection :: (ap1: Vector2, ap2: Vector2, bp1: Vector2, bp2: Vector2) -> bool {
		A := ap2 - ap1;
		B := bp2 - bp1;
		
		// compute the bottom
        // cross if flipped for some reason
		BxA := cross(A, B);
		if abs(BxA) <= EPSILON {
			// the line segments are parallel and don't intersect
			return false;
		}
		
		// compute the top
		ambxA := cross(A, ap1 - bp1);
		if abs(ambxA) <= EPSILON {
			// the line segments are coincident
			return false;
		}
		
		// compute tb
		tb := ambxA / BxA;
		if tb < 0.0 || tb > 1.0 {
			// no intersection
			return false;
		}
		
		// compute the intersection point
		ip := B * tb + bp1;
		
		// since both are segments we need to verify that
		// ta is also valid.
		// compute ta
		ta := dot((ip - ap1), A) / dot(A, A);
		if ta < 0.0 || ta > 1.0 {
			// no intersection
			return false;
		}
		
		return true;
    }

    is_visible :: (polygon: [] Vector2, i: int, j: int) -> bool {
        s := polygon.count;
		iv0, iv, iv1: Vector2;
		jv0, jv, jv1: Vector2;
		
		iv0 = polygon[ifx i == 0 then s - 1 else i - 1];
		iv = polygon[i];
		iv1 = polygon[ifx i + 1 == s then 0 else i + 1];
		
		jv0 = polygon[ifx j == 0 then s - 1 else j - 1];
		jv = polygon[j];
		jv1 = polygon[ifx j + 1 == s then 0 else j + 1];
		
		// can i see j
		if is_reflex(iv0, iv, iv1) {
			if left_on(iv, iv0, jv) && right_on(iv, iv1, jv) {
                return false;
            }
		} else {
			if right_on(iv, iv1, jv) || left_on(iv, iv0, jv) {
                return false;
            }
		}
		// can j see i
		if is_reflex(jv0, jv, jv1) {
			if left_on(jv, jv0, iv) && right_on(jv, jv1, iv) {
                return false;
            }
		} else {
			if right_on(jv, jv1, iv) || left_on(jv, jv0, iv) {
                return false;
            }
		}
		// make sure the segment from i to j doesn't intersect any edges
        for k: 0..s - 1 {
			ki1 := ifx k + 1 == s then 0 else k + 1;
			if k == i || k == j || ki1 == i || ki1 == j {
                continue;
            }
			k1 := polygon[k];
			k2 := polygon[ki1];
			
			if get_segment_intersection(iv, jv, k1, k2) {
                return false;
            }
		}
		
		return true;
    }

    // get the size of the given polygon
    size := polygon.count;
    
    // initialize
    upper_intersection: Vector2;
    lower_intersection: Vector2;
    upper_distance := FLOAT32_MAX;
    lower_distance := FLOAT32_MAX;
    closest_distance := FLOAT32_MAX;
    upper_index := 0;
    lower_index := 0;
    closest_index := 0;

    upper: [..] Vector2;
    defer array_free(upper);
    lower: [..] Vector2;
    defer array_free(lower);
    
    // loop over all the vertices
    for i: 0..size - 1 {
        // get the current vertex
        p: Vector2 = polygon[i];
        
        // get the adjacent vertices
        p0: Vector2 = polygon[ifx i - 1 < 0 then size - 1 else i - 1];
        p1: Vector2 = polygon[ifx i + 1 == size then 0 else i + 1];
        
        // check if the vertex is a reflex vertex
        if is_reflex(p0, p, p1) {
            // loop over the vertices to determine if both extended
            // adjacent edges intersect one edge (in which case a 
            // steiner point will be added)
            for j: 0..size - 1 {
                q: Vector2 = polygon[j];
                
                // get the adjacent vertices
                q0: Vector2 = polygon[ifx j - 1 < 0 then size - 1 else j - 1];
                q1: Vector2 = polygon[ifx j + 1 == size then 0 else j + 1];
                
                // create a storage location for the intersection point
                s: Vector2;
                
                // extend the previous edge
                // does the line p0->p go between the vertices q and q0
                if left(p0, p, q) && right_on(p0, p, q0) {
                    // get the intersection point
                    if get_intersection(p0, p, q, q0, *s) {
                        // make sure the intersection point is to the right of
                        // the edge p1->p (this makes sure its inside the polygon)
                        if right(p1, p, s) {
                            // get the distance from p to the intersection point s
                            dist := distance_squared(p, s);
                            // only save the smallest
                            if dist < lower_distance {
                                lower_distance = dist;
                                lower_intersection.x = s.x;
                                lower_intersection.y = s.y;
                                lower_index = j;
                            }
                        }
                    }
                }
                
                // extend the next edge
                // does the line p1->p go between q and q1
                if left(p1, p, q1) && right_on(p1, p, q) {
                    // get the intersection point
                    if get_intersection(p1, p, q, q1, *s) {
                        // make sure the intersection point is to the left of
                        // the edge p0->p (this makes sure its inside the polygon)
                        if left(p0, p, s) {
                            // get the distance from p to the intersection point s
                            dist := distance_squared(p, s);
                            // only save the smallest
                            if dist < upper_distance {
                                upper_distance = dist;
                                upper_intersection.x = s.x;
                                upper_intersection.y = s.y;
                                upper_index = j;
                            }
                        }
                    }
                }
            }
            
            // if the lower index and upper index are equal then this means
            // that the range of p only included an edge (both extended previous 
            // and next edges of p only intersected the same edge, therefore no
            // point exists within that range to connect to)
            if lower_index == (upper_index + 1) % size {
                // create a steiner point in the middle
                s := (upper_intersection + lower_intersection) * 0.5;
                
                // partition the polygon
                if i < upper_index {
                    add_all(*lower, sublist(polygon, i, upper_index + 1));
                    array_add(*lower, s);
                    array_add(*upper, s);
                    if lower_index != 0 {
                        add_all(*upper, sublist(polygon, lower_index, size));
                    }
                    add_all(*upper, sublist(polygon, 0, i + 1));
                } else {
                    if i != 0 {
                        add_all(*lower, sublist(polygon, i, size));
                    }
                    add_all(*lower, sublist(polygon, 0, upper_index + 1));
                    array_add(*lower, s);
                    array_add(*upper, s);
                    add_all(*upper, sublist(polygon, lower_index, i + 1));
                }
            } else {
                // otherwise we need to find the closest "visible" point to p
                if lower_index > upper_index {
                    upper_index += size;
                }
                
                closest_index = lower_index;
                // find the closest visible point
                for j: lower_index..upper_index {
                    jmod := j % size;
                    q: Vector2 = polygon[jmod];
                    
                    if q == p || q == p0 || q == p1 {
                        continue;
                    }
                    
                    // check the distance first, since this is generally
                    // a much faster operation than checking if its visible
                    dist := distance_squared(p, q);
                    if dist < closest_distance {
                        if is_visible(polygon, i, jmod) {
                            closest_distance = dist;
                            closest_index = jmod;
                        }
                    }
                }
                
                // once we find the closest partition the polygon
                if i < closest_index {
                    add_all(*lower, sublist(polygon, i, closest_index + 1));
                    if closest_index != 0 {
                        add_all(*upper, sublist(polygon, closest_index, size));
                    }
                    add_all(*upper, sublist(polygon, 0, i + 1));
                } else {
                    if i != 0 {
                        add_all(*lower, sublist(polygon, i, size));
                    }
                    add_all(*lower, sublist(polygon, 0, closest_index + 1));
                    add_all(*upper, sublist(polygon, closest_index, i + 1));
                }
            }
            
            // decompose the smaller first
            if lower.count < upper.count {
                decompose(lower, polygons);
                decompose(upper, polygons);
            } else {
                decompose(upper, polygons);
                decompose(lower, polygons);
            }
            
            // if the given polygon contains a reflex vertex, then return
            return;
        }
    }
    
    // if we get here, we know the given polygon has 0 reflex vertices
    // and is therefore convex, add it to the list of convex polygons
    if polygon.count < 3 {
        return; // assert(false);
    }
    vertices: [..] Vector2;
    array_reserve(*vertices, polygon.count);
    for v: polygon {
        array_add(*vertices, v);
    }
    array_add(polygons, vertices);
}

create_aabb :: (polygon: [] Vector2) -> AABB2 {
    if polygon.count == 0 {
        return .{};
    }

    aabb: AABB2 = ---;
    aabb.lower = polygon[0];
    aabb.upper = polygon[0];

    for i: 1..polygon.count - 1 {
        aabb.lower = min(aabb.lower, polygon[i]);
        aabb.upper = max(aabb.upper, polygon[i]);
    }

    return aabb;
}

// convex polygon stuff
is_convex :: (polygon: [] Vector2) -> bool {
    if polygon.count <= 3 {
        return true;
    }

    if polygon.count == 4 {
        return is_convex(polygon[0], polygon[1], polygon[2], polygon[3]);
    }

    // TODO we probably don't need to brute force it like this to test convexity?
    // still though I guess its pretty efficient
    for i: 0..polygon.count - 1 {
        i2 := (i + 1) % polygon.count;
        i3 := (i + 2) % polygon.count;
        i4 := (i + 3) % polygon.count;
        if !is_convex(polygon[i], polygon[i2], polygon[i3], polygon[i4]) {
            return false;
        }
    }

    return true;
}

intersect_ray_convex_polygon :: (ray: Ray2, polygon: [] Vector2) -> bool, first: float, last: float, last_normal: Vector2 {
    plane_normal :: (p1: Vector2, p2: Vector2) -> Vector2 {
        delta := p2 - p1;

        n: Vector2 = ---;
        n.x = -delta.y;
        n.y = delta.x;
        return normalize(n);
    }

    plane_distance :: (p: Vector2, normal: Vector2) -> float {
        return dot(p, normal);
    }

    // Compute direction vector for the segment
    d := ray.dir;
    // Set initial interval to being the whole segment. For a ray, tlast should be
    // set to +FLT_MAX. For a line, additionally tfirst should be set to –FLT_MAX
    first := 0.0;
    last := FLOAT32_MAX;
    last_normal: Vector2;
    // Intersect segment against each plane
    for index: 0..polygon.count - 1 {
        next_index := (index + 1) % polygon.count;

        n := plane_normal(polygon[index], polygon[next_index]);
        d := plane_distance(polygon[index], n);

        denom := dot(n, ray.dir);
        dist := d - dot(n, ray.p);
        // Test if segment runs parallel to the plane
        if denom == 0 {
            // If so, return “no intersection” if segment lies outside plane
            if dist < 0 {
                return false, 0, 0, .{};
            }
        } else {
            // Compute parameterized t value for intersection with current plane
            t := dist / denom;
            if denom < 0 {
                // When entering halfspace, update tfirst if t is larger
                if t > first {
                    first = t;
                }
            } else {
                // When exiting halfspace, update tlast if t is smaller
                if t < last {
                    last = t;
                    last_normal = n;
                }
            }

            // Exit with “no intersection” if intersection becomes empty
            if first > last {
                return false, 0, 0, .{};
            }
        }
    }

    // A nonzero logical intersection, so the segment intersects the polyhedron
    return true, first, last, last_normal;
}

// determines the length to move p2 out of p1
overlap :: (p1: [] Vector2, p2: [] Vector2, dir: Vector2) -> offset: Vector2, normal: Vector2, collision: bool {
    norm_dir := normalize(dir);
    largest_exit := 0.0;
    largest_exit_normal: Vector2;

    // check how far every point in p2 has to move to get out of p1
    for p: p2 {
        ray: Ray2 = ---;
        ray.p = p;
        ray.dir = norm_dir;

        hit, start, end, normal := interesct_ray_convex_polygon(ray, p1);
        if hit && end > largest_exit {
            largest_exit = end;
            largest_exit_normal = normal;
        }
    }

    // check how far every point in p1 has to move to get out of p2
    for p: p1 {
        ray: Ray2 = ---;
        ray.p = p;
        ray.dir = -norm_dir;
        hit, start, end, normal := interesct_ray_convex_polygon(ray, p2);
        if hit && end > largest_exit {
            largest_exit = end;
            largest_exit_normal = -normal;
        }
    }

    if largest_exit == 0 {
        return .{}, .{}, false;
    }

    return norm_dir * largest_exit, largest_exit_normal, true;
}

overlap :: (a: [] Vector2, b: [] Vector2) -> Vector2, bool {
    Projection :: struct {
        min: float;
        max: float;
    }

    // not okay right? overloaded return values?
    overlaps :: (p1: Projection, p2: Projection) -> bool {
        return p1.max > p2.min && p1.min < p2.max;
    }

    calc_overlaps :: (p1: Projection, p2: Projection) -> float {
        return min(p1.max, p2.max) - max(p1.min, p2.min);
    }

    project :: (points: [] Vector2, axis: Vector2) -> Projection {
        projection: Projection = ---;
        projection.min = dot(axis, points[0]);
        projection.max = projection.min;

        for i: 1..points.count - 1 {
            dot_p := dot(axis, points[i]);
            if dot_p < projection.min {
                projection.min = dot_p;
            } else if dot_p > projection.max {
                projection.max = dot_p;
            }
        }

        return projection;
    }

    aabb1 := create_aabb(a);
    aabb2 := create_aabb(b);

    if !intersects(aabb1, aabb2) {
        return .{}, false;
    }

    // pointers to each polygon so they can be swapped
    overlap := FLOAT32_MAX;
    oaxis: Vector2;
    sa: [] Vector2 = a;
    sb: [] Vector2 = b;

    a_location: Vector2;
    for point: a {
        a_location += point;
    }
    a_location /= a.count;

    b_location: Vector2;
    for point: b {
        b_location += point;
    }
    b_location /= b.count;

    for shape: 0..1 {
        if shape == 1 {
            sa, sb = swap(sa, sb);
        }

        // TODO in reality we can take advantage of the fact that we know the max polygon size
        axes: [..] Vector2;
        defer array_free(axes);

        array_resize(*axes, sa.count);

        for i: 0..axes.count - 1 {
            line: Line2 = ---;
            line.p1 = sa[i];
            line.p2 = sa[(i + 1) % sa.count];

            axes[i] = normalize(perp(line.p2 - line.p1));
        }

        for i: 0..axes.count - 1 {
            axis: Vector2 = axes[i];
            pa := project(sa, axis);
            pb := project(sb, axis);

            if !overlaps(pa, pb) {
                return .{}, false;
            } else {
                o := calc_overlaps(pa, pb);
                if o < overlap {
                    overlap = o;
                    oaxis = axis;
                }
            }
        }
    }
    
    // if the smallest penetration normal
    //     points into shape b,
    //     flip it
    if dot((b_location - a_location), oaxis) < 0 {
        oaxis *= -1;
    }

    // now oaxis is the axis along which
    //     the smallest penetration occurred
    // the resolution vector is that axis normal
    //     multiplied by the smallest 
    //     penetration amount
    resolution := oaxis * overlap;

    return resolution, true;
}

nearest_point :: (polygon: [] Vector2, point: Vector2) -> Vector2 {
    min_distance_squared := FLOAT32_MAX;
    min_distance_point: Vector2;

    for i: 0..polygon.count - 1 {
        line: Line2 = ---;
        line.p1 = polygon[i];
        line.p2 = polygon[(i + 1) % polygon.count];

        nearest := nearest_point(line, point);
        distance_squared := dot(nearest - point);

        if distance_squared < min_distance_squared {
            min_distance_squared = distance_squared;
            min_distance_point = nearest;
        }
    }

    return min_distance_point;
}

intersects :: (polygon: [] Vector2, point: Vector2) -> bool {
    // p202
    #if DEBUG validate_ccw(polygon);

    if polygon.count < 3 {
        return false;
    }

    // Test if point p lies inside ccw-specified convex n-gon given by vertices v[]
    // Do binary search over polygon vertices to find the fan triangle
    // (v[0], v[low], v[high]) the point p lies within the near sides of
    low := 0;
    high := polygon.count;
    
    mid := (low + high) / 2;
    triangle: Triangle2 = ---;
    triangle.a = polygon[0];
    triangle.b = polygon[mid];
    triangle.c = point;
    if is_ccw(triangle) {
        low = mid;
    } else {
        high = mid;
    }
    
    while low + 1 < high {
        mid = (low + high) / 2;
        triangle.a = polygon[0];
        triangle.b = polygon[mid];
        triangle.c = point;
        if is_ccw(triangle) {
            low = mid;
        } else {
            high = mid;
        }
    }
    // If point outside last (or first) edge, then it is not inside the n-gon
    if low == 0 || high == polygon.count {
        return false;
    }
    // p is inside the polygon if it is left of
    // the directed edge from v[low] to v[high]
    final: Triangle2 = ---;
    final.a = polygon[low];
    final.b = polygon[high];
    final.c = point;
    return is_ccw(final);
}

intersection :: (polygon: [] Vector2, line: Line2) -> Vector2, bool {
    // TODO do this better
    min_hit := false;
    min_point: Vector2;
    min_t := 1.0;
    t := 0.0;
    for i: 0..polygon.count - 1 {
        p1 := polygon[i];
        p2 := polygon[(i + 1) % polygon.count];

        poly_line: Line2 = ---;
        poly_line.p1 = p1;
        poly_line.p2 = p2;
        point, hit := intersection(poly_line, line, *t);

        #if DEBUG {
            // this should never be possible... right?
            if t > 1 && hit {
                assert(false);
            }
        }

        if hit && t <= min_t {
            min_t = t;
            min_point = point;
            min_hit = true;
        }
    }

    return min_point, min_hit;
}

intersection :: (polygon: [] Vector2, line: Line2, normal: *Vector2) -> Vector2, bool {
    // TODO do this better
    min_hit := false;
    min_point: Vector2;
    min_t := 1.0;
    t := 0.0;
    for i: 0..polygon.count - 1 {
        p1 := polygon[i];
        p2 := polygon[(i + 1) % polygon.count];

        poly_line: Line2 = ---;
        poly_line.p1 = p1;
        poly_line.p2 = p2;
        point, hit := intersection(poly_line, line, *t);

        #if DEBUG {
            // this should never be possible... right?
            if t > 1 && hit {
                assert(false);
            }
        }

        if hit && t <= min_t {
            min_t = t;
            min_point = point;
            min_hit = true;
            << normal = perp(poly_line.p2 - poly_line.p1);
        }
    }

    return min_point, min_hit;
}

FixedPolygon :: struct (max_count: int) {
    vertices: [max_count] Vector2;
    count: int;
}

operator == :: (fixed: FixedPolygon($N), other: FixedPolygon($M)) -> bool {
    if fixed.count != other.count {
        return false;
    }

    for i: 0..fixed.count - 1 {
        if fixed[i] != other[i] {
            return false;
        }
    }

    return true;
}

operator [] :: (fixed: FixedPolygon($N), index: int) -> Vector2 {
    return fixed.vertices[index];
}

fixed_polygon :: (vertices: [$N] Vector2, count: int) -> FixedPolygon(N) {
    fixed: FixedPolygon(N);
    fixed.vertices = vertices;
    fixed.count = count;
    return fixed;
}

reverse :: (fixed: *FixedPolygon($N)) {
    for i: 0..fixed.count / 2 - 1 {
        fixed.vertices[i], fixed.vertices[fixed.count - i - 1] = swap(fixed.vertices[i], fixed.vertices[fixed.count - i - 1]);
    }
}

// TODO wrong name
contains :: (fixed: FixedPolygon($N), other: FixedPolygon($M)) -> bool {
    if fixed.count < other.count {
        return false;
    }

    for i: 0..fixed.count - 1 {
        if fixed[i] != other[i] {
            return false;
        }
    }

    return true;
}

split_convex_polygon :: (vertices: [] Vector2, $max_count: int) -> [..] FixedPolygon(max_count) {
    poly_list: [..] FixedPolygon(max_count);

    assert(vertices.count >= 3, "You cannot split a polygon with fewer than 3 vertices.");

    final_polygon_count: int = roundi(ceil((vertices.count - 2.0) / (max_count - 2.0)));
    if final_polygon_count == 1 {
        split_polygon: FixedPolygon(max_count);
        split_polygon.count = vertices.count;
        for i: 0..vertices.count - 1 {
            split_polygon.vertices[i] = vertices[i];
        }

        array_add(*poly_list, split_polygon);

        return poly_list;
    }

    iterate_offset: float = (vertices.count - 1.0) / final_polygon_count;

    indices: [..] int;
    defer array_free(indices);

    array_add(*indices, 0);
    for i: 0..final_polygon_count - 2 {
        array_add(*indices, roundi(ceil(iterate_offset * (i + 1))));
    }

    for i: 0..indices.count - 1 {
        split_polygon: FixedPolygon(max_count);

        split_polygon.vertices[split_polygon.count] = vertices[0];
        split_polygon.count += 1;

        start_index := indices[i];
        if start_index != 0 {
            split_polygon.vertices[split_polygon.count] = vertices[start_index];
            split_polygon.count += 1;
        }

        end_index := ifx i + 1 < indices.count then indices[i + 1] else vertices.count - 1;
        for index: start_index + 1..end_index {
            split_polygon.vertices[split_polygon.count] = vertices[index];
            split_polygon.count += 1;
        }

        array_add(*poly_list, split_polygon);
    }

    return poly_list;
}

// cylinder stuff
intersection :: (cylinder: Cylinder, line: Line3) -> Vector3, float, bool {
    // p197
    t: float;
    sa := line.p1;
    sb := line.p2;
    q := cylinder.q;
    p := cylinder.p;
    r := cylinder.r;
    d := q - p;
    m := sa - p;
    n := sb - sa;
    md := dot(m, d);
    nd := dot(n, d);
    dd := dot(d, d);

    // segment outside p side of cylinder
    if md < 0 && md + nd < 0 return .{}, 0, false;
    // segment outside of q side of cylinder
    if md > dd && md + nd > dd return .{}, 0, false;

    nn := dot(n, n);
    mn := dot(m, n);
    a := dd * nn - nd * nd;
    k := dot(m, m) - r * r;
    c := dd * k - md * md;
    if abs(a) < EPSILON {
        // segment runs parallel to cylinder
        if c > 0 return .{}, 0, false;

        if md < 0 {
            t = -mn / nn;
        } else if md > dd {
            t = (nd - mn) / nn;
        } else {
            t = 0;
        }
        return sa + (sb - sa) * t, t, true;
    }

    b := dd * mn - nd * md;
    discr := b * b - a * c;
    if discr < 0 return .{}, 0, false;

    t = (-b - sqrt(discr)) / a;
    if t < 0 || t > 1 return .{}, 0, false;

    if md + t * nd < 0 {
        // intersection outside of cylinder on p side
        if nd <= 0 return .{}, 0, false;
        t = -md / nd;
        if k + 2 * t * (mn + t * nn) <= 0 {
            return sa + (sb - sa) * t, t, true;
        } else {
            return .{}, 0, false;
        }
    } else if md + t * nd > dd {
        if nd >= 0 return .{}, 0, false;
        t = (dd - md) / nd;
        if k + dd - 2 * md + t * (2 * (mn - nd) + t * nn) <= 0 {
            return sa + (sb - sa) * t, t, true;
        } else {
            return .{}, 0, false;
        }
    }

    return sa + (sb - sa) * t, t, true;
}

nearest_point :: (cylinder: Cylinder, point: Vector3) -> Vector3, float {
    ab := cylinder.q - cylinder.p;
    abdot := dot(ab, ab);
    if abdot < EPSILON {
        return point, 0;
    }
    
    t := dot(point - cylinder.p, ab) / abdot;
    if t < 0 {
        plane_d := dot(ab, cylinder.p);
        plane_t := dot(ab, point) - plane_d;
        projected := point - plane_t * ab;
        if distance_squared(projected, cylinder.p) > cylinder.r * cylinder.r {
            return normalize(projected - cylinder.p) * cylinder.r + cylinder.p, t;
        } else {
            return projected, t;
        }
    }
    if t > 1 {
        plane_d := dot(ab, cylinder.q);
        plane_t := dot(ab, point) - plane_d;
        projected := point - plane_t * ab;
        if distance_squared(projected, cylinder.q) > cylinder.r * cylinder.r {
            return normalize(projected - cylinder.q) * cylinder.r + cylinder.q, t;
        } else {
            return projected, t;
        }
    }

    projected := cylinder.p + t * ab;

    if distance_squared(projected, point) > cylinder.r * cylinder.r {
        return normalize(point - projected) * cylinder.r + projected, t;
    } else {
        return point, t;
    }
}

contains :: (cylinder: Cylinder, point: Vector3) -> bool {
    // p128
    ab := cylinder.q - cylinder.p;
    abdot := dot(ab, ab);
    if abdot < EPSILON {
        return false;
    }
    
    t := dot(point - cylinder.p, ab) / abdot;
    if t < 0.0 {
        return false;
    }
    if t > 1.0 {
        return false;
    }

    projected_point := cylinder.p + t * ab;
    return distance_squared(projected_point, point) <= cylinder.r * cylinder.r;
}

// sphere stuff
calculate_bounding_sphere :: (vertices: $T) -> Sphere {
    // ritters algorithm

    start: Vector3;
    for vertex: vertices {
        start = vertex;
        break;
    }

    farthest_dist := 0.0;
    farthest_a: Vector3;

    for vertex: vertices {
        d2 := distance_squared(start, vertex);
        if d2 > farthest_dist {
            farthest_dist = d2;
            farthest_a = vertex;
        }
    }

    assert(farthest_dist > 0);

    if farthest_dist == 0 {
        return .{};
    }

    farthest_dist = 0.0;
    farthest_b: Vector3;

    for vertex: vertices {
        d2 := distance_squared(farthest_a, vertex);
        if d2 > farthest_dist {
            farthest_dist = d2;
            farthest_b = vertex;
        }
    }

    assert(farthest_dist > 0);

    if farthest_dist == 0 {
        return .{};
    }

    sphere: Sphere;
    sphere.center = farthest_a / 2.0 + farthest_b / 2.0;
    sphere.radius = distance(farthest_a, farthest_b) / 2.0;

    for vertex: vertices {
        d2 := distance_squared(sphere.center, vertex);
        if d2 <= sphere.radius * sphere.radius {
            continue;
        }

        d := sqrt(d2);

        new_radius := (sphere.radius + d) / 2.0;
        sphere.center = sphere.center + ((new_radius - sphere.radius) / d) * (vertex - sphere.center);
        sphere.radius = new_radius;
    }

    #if DEBUG {
        for vertex: vertices {
            dist := distance(sphere.center, vertex);
            assert(dist <= sphere.radius + 0.001, "Found invalid vertex after calculating bounding sphere. % > %\n", dist, sphere.radius);
        }
    }

    return sphere;
}

// Determine whether plane p intersects sphere s
intersection :: (sphere: Sphere, ray: Ray3) -> Vector3, bool {
    t: float = 0;
    vector, value := intersection(sphere, ray, *t);
    return vector, value;
}

intersection :: (sphere: Sphere, ray: Ray3, t: *float) -> Vector3, bool {
    // p178
    #if DEBUG validate_unit_vector(ray.dir);

    m := ray.p - sphere.center;
    b := dot(m, ray.dir);
    c := dot(m, m) - sphere.radius * sphere.radius;
    // Exit if r’s origin outside s (c > 0) and r pointing away from s (b > 0)
    if c > 0 && b > 0 {
        return .{0, 0, 0}, false;
    }
    discr := b * b - c;
    // A negative discriminant corresponds to ray missing sphere
    if discr < 0 {
        return .{0, 0, 0}, false;
    }
    // Ray now found to intersect sphere, compute smallest t value of intersection
    << t = -b - sqrt(discr);
    // If t is negative, ray started inside sphere so clamp t to zero
    if << t < 0 {
        << t = 0;
    }
    return ray.p + << t * ray.dir, true;
}

intersects :: (sphere: Sphere, ray: Ray3) -> bool {
    // p179
    #if DEBUG validate_unit_vector(ray.dir);
    
    m := ray.p - sphere.center;
    c := dot(m, m) - sphere.radius * sphere.radius;
    // If there is definitely at least one real root, there must be an intersection
    if c <= 0 {
        return true;
    }
    b := dot(m, ray.dir);
    // Early exit if ray origin outside sphere and ray pointing away from sphere
    if b > 0 {
        return false;
    }
    disc := b * b - c;
    // A negative discriminant corresponds to ray missing sphere
    if disc < 0 {
        return false;
    }
    // Now ray must hit sphere
    return true;
}

intersects :: (sphere: Sphere, plane: Plane3) -> bool {
    // p160
    #if DEBUG validate_unit_vector(plane.n);

    // for a point gives the signed distance of the point to the plane
    dist := dot(sphere.center, plane.n) - plane.d;
    // If sphere center within +/-radius from plane, plane intersects sphere
    return abs(dist) <= sphere.radius;
}

contains :: (sphere: Sphere, point: Vector3) -> bool {
    return distance_squared(sphere.center, point) <= sphere.radius * sphere.radius;
}

// plane stuff
intersection :: (plane1: Plane3, plane2: Plane3) -> Ray3, bool {
    // p208
    #if DEBUG validate_unit_vector(plane1.n);
    #if DEBUG validate_unit_vector(plane2.n);

    // Given planes p1 and p2, compute line L = p+t*d of their intersection.
    // Return 0 if no such line exists
    // Compute direction of intersection line
    d := cross(plane1.n, plane2.n);
    // If d is zero, the planes are parallel (and separated)
    // or coincident, so they’re not considered intersecting
    if dot(d, d) < EPSILON {
        return .{.{0, 0, 0}, .{0, 0, 0}}, false;
    }

    d11 := dot(plane1.n, plane1.n);
    d12 := dot(plane1.n, plane2.n);
    d22 := dot(plane2.n, plane2.n);
    denom := d11 * d22 - d12 * d12;
    k1 := (plane1.d * d22 - plane2.d * d12) / denom;
    k2 := (plane2.d * d11 - plane1.d * d12) / denom;

    ray: Ray3 = ---;
    ray.p = k1 * plane1.n + k2 * plane2.n;
    ray.dir = d;
    return ray, true;
}

intersection_simple :: (plane: Plane3, ray: Ray3) -> Vector3, float {
    // for optimized version of intersection when you don't care about unit vectors either
    t := (plane.d - dot(plane.n, ray.p)) / dot(plane.n, ray.dir);
    return ray.p + t * ray.dir, t;
}

intersection :: (plane: Plane3, ray: Ray3, $allow_negative: bool = false) -> Vector3, bool, float {
    // p176
    #if DEBUG validate_unit_vector(plane.n);
    #if DEBUG validate_unit_vector(ray.dir);

    // does not handle division by 0
    // compute the t value for the directed line ab intersecting the plane
    t := (plane.d - dot(plane.n, ray.p)) / dot(plane.n, ray.dir);

    #if allow_negative {
        return ray.p + t * ray.dir, true, t;
    } else {
        if t >= 0 {
            return ray.p + t * ray.dir, true, t;
        }

        return .{0, 0, 0}, false, 0;
    }
}

intersection :: (plane: Plane3, line: Line3) -> Vector3, bool {
    t: float = 0;
    point, value := intersection(plane, line, *t);
    return point, value;
}

intersection :: (plane: Plane3, line: Line3, t: *float) -> Vector3, bool {
    // p176
    #if DEBUG validate_unit_vector(plane.n);

    // does not handle division by 0
    // Compute the t value for the directed line ab intersecting the plane
    ab := line.p2 - line.p1;
    << t = (plane.d - dot(plane.n, line.p1)) / dot(plane.n, ab);
    // If t in [0..1] compute and return intersection point
    if << t >= 0 && << t <= 1 {
        return line.p1 + << t * ab, true;
    }
    // Else no intersection
    return .{0, 0, 0}, false;
}

intersects :: (plane: Plane3, line: Line3) -> bool {
    t: float = 0;
    return intersects(plane, line, *t);
}

intersects :: (plane: Plane3, line: Line3, t: *float) -> bool {
    // p176
    #if DEBUG validate_unit_vector(plane.n);

    // does not handle division by 0
    // Compute the t value for the directed line ab intersecting the plane
    ab := line.p2 - line.p1;
    << t = (plane.d - dot(plane.n, line.p1)) / dot(plane.n, ab);
    // If t in [0..1] compute and return intersection point
    if << t >= 0 && << t <= 1 {
        return true;
    }
    // Else no intersection
    return false;
}

outside :: (plane: Plane3, point: Vector3) -> bool {
    #if DEBUG validate_unit_vector(plane.n);

    return dot(point, plane.n) > plane.d;
}

inside :: (plane: Plane3, point: Vector3) -> bool {
    #if DEBUG validate_unit_vector(plane.n);

    return dot(point, plane.n) <= plane.d;
}

// Determine whether sphere s is fully behind (inside negative halfspace of) plane p
inside :: (plane: Plane3, sphere: Sphere) -> bool {
    // p161
    #if DEBUG validate_unit_vector(plane.n);

    dist := dot(sphere.center, plane.n) - plane.d;
    return dist < -sphere.radius;
}

nearest_point :: (plane: $T/AnyPlane3, point: $P/AnyVector3) -> P {
    // p127
    #if DEBUG validate_unit_vector(plane.n);
    
    t := dot(plane.n, point) - plane.d;
    return point - t * plane.n;
}

distance :: (plane: Plane3, point: Vector3) -> float {
    #if DEBUG validate_unit_vector(plane.n);

    return dot(point, plane.n) - plane.d;
    // return (Dot(p.n, q) - p.d) / Dot(p.n, p.n); if plane equation is not normalized
}

distance :: (plane: Plane3_64, point: Vector3_64) -> float64 {
    #if DEBUG validate_unit_vector(plane.n);

    return dot(point, plane.n) - plane.d;
    // return (Dot(p.n, q) - p.d) / Dot(p.n, p.n); if plane equation is not normalized
}

// this function is just going to assume up is 0, 1, 0 and correct it arbitrarily since that's the behavior I currently need
// returns the 2d coordinates in the newly determined system
// it also returns the right and up vectors in 3d space
convert_coordinates :: (plane: Plane3, origin: Vector3, point: Vector3) -> Vector2, Vector3, Vector3 {
    #if DEBUG validate_unit_vector(plane.n);

    up := Vector3.{0, 1, 0};
    if abs(dot(plane.n, up)) > 0.5 {
        up = Vector3.{0, 0, -1};
    }

    projected := nearest_point(plane, point);
    plane_right := normalize(cross(plane.n, up));
    plane_up := normalize(cross(plane_right, plane.n));

    assert(distance(plane, origin) < 0.00001, "Invalid plane origin.\n");
    point_delta := projected - origin;

    return Vector2.{dot(point_delta, plane_right), dot(point_delta, plane_up)}, plane_right, plane_up;
}

convert_coordinates :: (plane: Plane3_64, origin: Vector3_64, point: Vector3_64) -> Vector2_64, Vector3_64, Vector3_64 {
    #if DEBUG validate_unit_vector(plane.n);

    up := Vector3_64.{0, 1, 0};
    if abs(dot(plane.n, up)) > 0.5 {
        up = Vector3_64.{0, 0, -1};
    }

    projected := nearest_point(plane, point);
    plane_right := normalize(cross(plane.n, up));
    plane_up := normalize(cross(plane_right, plane.n));

    assert(distance(plane, origin) < 0.00001, "Invalid plane origin.\n");
    point_delta := projected - origin;

    return Vector2_64.{dot(point_delta, plane_right), dot(point_delta, plane_up)}, plane_right, plane_up;
}

// circle stuff
nearest_point :: (circle: Circle3, ray: Ray3) -> Vector3 {
    // nearest point on circle
    #if DEBUG validate_unit_vector(circle.n);
    #if DEBUG validate_unit_vector(ray.dir);

    // this whole method is probably slightly wrong bc im mostly just projecting onto planes and solving the edge case of orthogonal

    circle_plane := create_plane3(circle.p, circle.n);

    // if the ray and the circle are tangential, we have to calculate it a different way
    if abs(dot(circle.n, ray.dir)) < EPSILON {
        plane_ray_point := nearest_point(circle_plane, ray.p);
        plane_ray_dir := normalize(nearest_point(circle_plane, ray.dir));
        plane_ray := Ray3.{plane_ray_point, plane_ray_dir};

        nearest := nearest_point(plane_ray, circle.p);
        dist := length(nearest - circle.p);
        if dist >= circle.r {
            return circle.p + normalize(nearest - circle.p) * circle.r;
        } else {
            // the projected ray collides with 2 points on the circle
            sphere := Sphere.{circle.p, circle.r};
            sphere_point := intersection(sphere, plane_ray);
            return sphere_point;
        }
    } else {
        plane_point := intersection(circle_plane, ray);
        delta := plane_point - circle.p;
        if length(delta) < EPSILON {
            plane_ray_dir := normalize(nearest_point(circle_plane, ray.dir));
            return circle.p - plane_ray_dir * circle.r;
        } else {
            return circle.p + normalize(delta) * circle.r;
        }
    }
}

// aabb stuff
get_aabb_points :: (aabb: AABB3) -> [8] Vector3 {
    aabb_points: [8] Vector3 = ---;
    aabb_points[0] = Vector3.{aabb.lower.x, aabb.lower.y, aabb.lower.z};
    aabb_points[1] = Vector3.{aabb.lower.x, aabb.lower.y, aabb.upper.z};
    aabb_points[2] = Vector3.{aabb.lower.x, aabb.upper.y, aabb.lower.z};
    aabb_points[3] = Vector3.{aabb.lower.x, aabb.upper.y, aabb.upper.z};
    aabb_points[4] = Vector3.{aabb.upper.x, aabb.lower.y, aabb.lower.z};
    aabb_points[5] = Vector3.{aabb.upper.x, aabb.lower.y, aabb.upper.z};
    aabb_points[6] = Vector3.{aabb.upper.x, aabb.upper.y, aabb.lower.z};
    aabb_points[7] = Vector3.{aabb.upper.x, aabb.upper.y, aabb.upper.z};
    return aabb_points;
}

get_aabb_points :: (transform: Matrix4, aabb: AABB3) -> [8] Vector3 {
    aabb_points: [8] Vector3 = ---;
    aabb_points[0] = inline transform_point(transform, Vector3.{aabb.lower.x, aabb.lower.y, aabb.lower.z});
    aabb_points[1] = inline transform_point(transform, Vector3.{aabb.lower.x, aabb.lower.y, aabb.upper.z});
    aabb_points[2] = inline transform_point(transform, Vector3.{aabb.lower.x, aabb.upper.y, aabb.lower.z});
    aabb_points[3] = inline transform_point(transform, Vector3.{aabb.lower.x, aabb.upper.y, aabb.upper.z});
    aabb_points[4] = inline transform_point(transform, Vector3.{aabb.upper.x, aabb.lower.y, aabb.lower.z});
    aabb_points[5] = inline transform_point(transform, Vector3.{aabb.upper.x, aabb.lower.y, aabb.upper.z});
    aabb_points[6] = inline transform_point(transform, Vector3.{aabb.upper.x, aabb.upper.y, aabb.lower.z});
    aabb_points[7] = inline transform_point(transform, Vector3.{aabb.upper.x, aabb.upper.y, aabb.upper.z});
    return aabb_points;
}

transform_aabb :: (matrix: Matrix4, aabb: AABB3) -> AABB3 {
    aabb_points := get_aabb_points(aabb);

    transformed: AABB3 = ---;
    transformed.lower = inline transform_point(matrix, aabb_points[0]);
    transformed.upper = transformed.lower;

    for i: 1..aabb_points.count - 1 {
        point := inline transform_point(matrix, aabb_points[i]);
        transformed.lower = min(transformed.lower, point);
        transformed.upper = max(transformed.upper, point);
    }

    return transformed;
}

intersects :: (aabb: AABB3, plane: Plane3) -> bool {
    // realtime physics, p. 164
    // These two lines not necessary with a (center, extents) AABB representation
    c := (aabb.upper + aabb.lower) * 0.5; // Compute AABB center
    e := aabb.upper - c; // Compute positive extents
    // Compute the projection interval radius of b onto L(t) = b.c + t * p.n
    r := e.x * abs(plane.n.x) + e.y * abs(plane.n.y) + e.z * abs(plane.n.z);
    // Compute distance of box center from plane
    s := dot(plane.n, c) - plane.d;
    // Intersection occurs when distance s falls within [-r,+r] interval
    return abs(s) <= r;
}

intersects :: (aabb: AABB3, triangle: Triangle3) -> bool {
    // realtime physics, p. 171
    p0: float = ---;
    p2: float = ---;
    r: float = ---;

    // compute box center and extents (if not already given in that format)
    c: Vector3 = (aabb.lower + aabb.upper) * 0.5;
    e0: float = (aabb.upper.x - aabb.lower.x) * 0.5;
    e1: float = (aabb.upper.y - aabb.lower.y) * 0.5;
    e2: float = (aabb.upper.z - aabb.lower.z) * 0.5;

    // translate triangle as conceptually moving AABB to origin
    v0: Vector3 = triangle.a - c;
    v1: Vector3 = triangle.b - c;
    v2: Vector3 = triangle.c - c;

    // compute edge vectors for triangle
    f0 := v1 - v0;
    f1 := v2 - v1;
    f2 := v0 - v2;

    // test axes a00..a22 (category 3)
    // test axis a00
    p0 = v0.z * v1.y - v0.y * v1.z;
    p2 = v2.z * (v1.y - v0.y) - v2.z * (v1.z - v0.z);
    r = e1 * abs(f0.z) + e2 * abs(f0.y);
    if max(-max(p0, p2), min(p0, p2)) > r return false; // axis is a separating axis

    // repeat similar tests for remaining axes a01..a22
    // test axes a01 and a02
    p0 = v0.x * v1.z - v0.z * v1.x;
    p2 = v2.x * (v1.z - v0.z) - v2.z * (v1.x - v0.x);
    r = e0 * abs(f0.z) + e2 * abs(f0.x);
    if max(-max(p0, p2), min(p0, p2)) > r return false; // axis is a separating axis

    // test axes a10 and a12
    p0 = v0.z * v1.x - v0.x * v1.z;
    p2 = v2.z * (v1.x - v0.x) - v2.x * (v1.z - v0.z);
    r = e0 * abs(f0.z) + e2 * abs(f0.x);
    if max(-max(p0, p2), min(p0, p2)) > r return false; // axis is a separating axis

    // test axes a20 and a21
    p0 = v0.y * v1.x - v0.x * v1.y;
    p2 = v2.y * (v1.x - v0.x) - v2.x * (v1.y - v0.y);
    r = e0 * abs(f0.y) + e1 * abs(f0.x);
    if max(-max(p0, p2), min(p0, p2)) > r return false; // axis is a separating axis

    // test axes a22
    p0 = v0.y * v1.z - v0.z * v1.y;
    p2 = v2.y * (v1.z - v0.z) - v2.z * (v1.y - v0.y);
    r = e0 * abs(f0.y) + e1 * abs(f0.x);
    if max(-max(p0, p2), min(p0, p2)) > r return false; // axis is a separating axis

    // test the three axes corresponding to the face normals of AABB b (category 1).
    // exit if...
    // ... [-e0, e0] and [min(v0.x,v1.x,v2.x), max(v0.x,v1.x,v2.x)] do not overlap
    if max(v0.x, v1.x, v2.x) < -e0 || min(v0.x, v1.x, v2.x) > e0
        return false;
    // ... [-e1, e1] and [min(v0.y,v1.y,v2.y), max(v0.y,v1.y,v2.y)] do not overlap
    if max(v0.y, v1.y, v2.y) < -e1 || min(v0.y, v1.y, v2.y) > e1
        return false;
    // ... [-e2, e2] and [min(v0.z,v1.z,v2.z), max(v0.z,v1.z,v2.z)] do not overlap
    if max(v0.z, v1.z, v2.z) < -e2 || min(v0.z, v1.z, v2.z) > e2
        return false;

    // test separating axis corresponding to triangle face normal (category 2)
    plane: Plane3 = ---;
    plane.n = cross(f0, f1);
    plane.d = dot(plane.n, v0);

    // aabb, plane
    return inline intersects(aabb, plane);
}

intersection :: (aabb: AABB2, ray: Ray2) -> Vector2, bool {
    t: float = 0;
    vector, value := intersection(aabb, ray, *t);
    return vector, value;
}

intersection :: (aabb: AABB3, ray: Ray3) -> Vector3, bool {
    t: float = 0;
    vector, value := intersection(aabb, ray, *t);
    return vector, value;
}

intersection :: (aabb: AABB2, ray: Ray2, t: *float) -> Vector2, bool {
    // p180
    #if DEBUG validate_unit_vector(ray.dir);

    t.* = 0; // set to -FLT_MAX to get first hit on line
    tmax := FLOAT32_MAX; // set to max distance ray can travel (for segment)
    // For all three slabs
    if abs(ray.dir.x) < EPSILON {
        // Ray is parallel to slab. No hit if origin not within slab
        if ray.p.x < aabb.lower.x || ray.p.x > aabb.upper.x {
            return .{0, 0}, false;
        }
    } else {
        // Compute intersection t value of ray with near and far plane of slab
        ood := 1.0 / ray.dir.x;
        t1 := (aabb.lower.x - ray.p.x) * ood;
        t2 := (aabb.upper.x - ray.p.x) * ood;
        // Make t1 be intersection with near plane, t2 with far plane
        if t1 > t2 {
            t1, t2 = swap(t1, t2);
        }
        // Compute the intersection of slab intersection intervals
        if t1 > << t {
            << t = t1;
        }
        if t2 > tmax {
            tmax = t2;
        }
        // Exit with no collision as soon as slab intersection becomes empty
        if << t > tmax {
            return .{0, 0}, false;
        }
    }
    if abs(ray.dir.y) < EPSILON {
        // Ray is parallel to slab. No hit if origin not within slab
        if ray.p.y < aabb.lower.y || ray.p.y > aabb.upper.y {
            return .{0, 0}, false;
        }
    } else {
        // Compute intersection t value of ray with near and far plane of slab
        ood := 1.0 / ray.dir.y;
        t1 := (aabb.lower.y - ray.p.y) * ood;
        t2 := (aabb.upper.y - ray.p.y) * ood;
        // Make t1 be intersection with near plane, t2 with far plane
        if t1 > t2 {
            t1, t2 = swap(t1, t2);
        }
        // Compute the intersection of slab intersection intervals
        if t1 > << t {
            << t = t1;
        }
        if t2 > tmax {
            tmax = t2;
        }
        // Exit with no collision as soon as slab intersection becomes empty
        if << t > tmax {
            return .{0, 0}, false;
        }
    }
    // Ray intersects all 3 slabs. Return point (q) and intersection t value (tmin)
    return ray.p + ray.dir * << t, true;
}

intersection :: (aabb: AABB3, ray: Ray3, tmin: *float) -> Vector3, bool {
    // p180
    #if DEBUG validate_unit_vector(ray.dir);

    p := ray.p.component;
    d := ray.dir.component;
    amin := aabb.lower.component;
    amax := aabb.upper.component;

    << tmin = 0;
    tmax := FLOAT32_MAX;

    for i: 0..2 {
        if abs(d[i]) < EPSILON {
            if p[i] < amin[i] || p[i] > amax[i] {
                return .{}, false;
            }
        } else  {
            t1 := (amin[i] - p[i]) / d[i];
            t2 := (amax[i] - p[i]) / d[i];

            if t1 > t2 {
                t1, t2 = swap(t1, t2);
            }

            << tmin = max(<< tmin, t1);
            tmax = min(tmax, t2);
        }
    }

    if tmax < (<< tmin) {
        return .{}, false;
    }

    // ray intersects all 3 slabs
    q := ray.p + ray.dir * (<< tmin);
    return q, true;
}

intersects :: (aabb: AABB2, line: Line2) -> bool {
    // p183
    e := aabb.upper - aabb.lower;
    d := line.p2 - line.p1;
    m := line.p1 + line.p2 - aabb.lower - aabb.upper;
    // Try world coordinate axes as separating axes
    adx := abs(d.x);
    if abs(m.x) > e.x + adx {
        return false;
    }
    ady := abs(d.y);
    if abs(m.y) > e.y + ady {
        return false;
    }
    // Add in an epsilon term to counteract arithmetic errors when segment is
    // (near) parallel to a coordinate axis (see text for detail)
    adx += EPSILON;
    ady += EPSILON;
    // Try cross products of segment direction vector with coordinate axes
    if abs(m.x * d.y - m.y * d.x) > e.x * ady + e.y * adx {
        return false;
    }
    // No separating axis found; segment must be overlapping AABB
    return true;
}

intersects :: (aabb: AABB3, line: Line3) -> bool {
    // p183
    e := aabb.upper - aabb.lower;
    d := line.p2 - line.p1;
    m := line.p1 + line.p2 - aabb.lower - aabb.upper;
    // Try world coordinate axes as separating axes
    adx := abs(d.x);
    if abs(m.x) > e.x + adx {
        return false;
    }
    ady := abs(d.y);
    if abs(m.y) > e.y + ady {
        return false;
    }
    adz := abs(d.z);
    if abs(m.z) > e.z + adz {
        return false;
    }
    // Add in an epsilon term to counteract arithmetic errors when segment is
    // (near) parallel to a coordinate axis (see text for detail)
    adx += EPSILON;
    ady += EPSILON;
    adz += EPSILON;
    // Try cross products of segment direction vector with coordinate axes
    if abs(m.y * d.z - m.z * d.y) > e.y * adz + e.z * ady {
        return false;
    }
    if abs(m.z * d.x - m.x * d.z) > e.x * adz + e.z * adx {
        return false;
    }
    if abs(m.x * d.y - m.y * d.x) > e.x * ady + e.y * adx {
        return false;
    }
    // No separating axis found; segment must be overlapping AABB
    return true;
}

nearest_point :: (aabb: AABB2, point: Vector2) -> Vector2 {
    // p130
    nearest: Vector2 = ---;

    x := point.x;
    x = max(x, aabb.lower.x);
    x = min(x, aabb.upper.x);
    nearest.x = x;
    
    y := point.y;
    y = max(y, aabb.lower.y);
    y = min(y, aabb.upper.y);
    nearest.y = y;

    return nearest;
}

nearest_point :: (aabb: AABB3, point: Vector3) -> Vector3 {
    // p130
    nearest: Vector3 = ---;

    x := point.x;
    x = max(x, aabb.lower.x);
    x = min(x, aabb.upper.x);
    nearest.x = x;
    
    y := point.y;
    y = max(y, aabb.lower.y);
    y = min(y, aabb.upper.y);
    nearest.y = y;
    
    z := point.z;
    z = max(z, aabb.lower.z);
    z = min(z, aabb.upper.z);
    nearest.z = z;

    return nearest;
}

distance :: (aabb: AABB2, point: Vector2) -> float {
    return sqrt(distance_squared(aabb, point));
}

distance :: (aabb: AABB3, point: Vector3) -> float {
    return sqrt(distance_squared(aabb, point));
}

distance_squared :: (aabb: AABB2, point: Vector2) -> float {
    // p131
    dist: float = 0;

    if point.x < aabb.lower.x {
        dist += (aabb.lower.x - point.x) * (aabb.lower.x - point.x);
    }
    if point.x > aabb.upper.x {
        dist += (point.x - aabb.upper.x) * (point.x - aabb.upper.x);
    }
    
    if point.y < aabb.lower.y {
        dist += (aabb.lower.y - point.y) * (aabb.lower.y - point.y);
    }
    if point.y > aabb.upper.y {
        dist += (point.y - aabb.upper.y) * (point.y - aabb.upper.y);
    }

    return dist;
}

distance_squared :: (aabb: AABB3, point: Vector3) -> float {
    // p131
    dist: float = 0;

    if point.x < aabb.lower.x {
        dist += (aabb.lower.x - point.x) * (aabb.lower.x - point.x);
    }
    if point.x > aabb.upper.x {
        dist += (point.x - aabb.upper.x) * (point.x - aabb.upper.x);
    }
    
    if point.y < aabb.lower.y {
        dist += (aabb.lower.y - point.y) * (aabb.lower.y - point.y);
    }
    if point.y > aabb.upper.y {
        dist += (point.y - aabb.upper.y) * (point.y - aabb.upper.y);
    }
    
    if point.z < aabb.lower.z {
        dist += (aabb.lower.z - point.z) * (aabb.lower.z - point.z);
    }
    if point.z > aabb.upper.z {
        dist += (point.z - aabb.upper.z) * (point.z - aabb.upper.z);
    }

    return dist;
}

intersects :: (a: AABB2, b: AABB2) -> bool {
    d1 := b.lower - a.upper;
    d2 := a.lower - b.upper;

    if d1.x > 0 || d1.y > 0 {
        return false;
    }

    if d2.x > 0 || d2.y > 0 {
        return false;
    }

    return true;
}

intersects :: (a: AABB3, b: AABB3) -> bool {
    d1 := b.lower - a.upper;
    d2 := a.lower - b.upper;

    avoid := d1.x > 0;
    avoid = avoid || d1.y > 0;
    avoid = avoid || d1.z > 0;
    avoid = avoid || d2.x > 0;
    avoid = avoid || d2.y > 0;
    avoid = avoid || d2.z > 0;

    if avoid {
        return false;
    }

    return true;
}

intersects :: (aabb: AABB2, ray: Ray2) -> bool {
    #if DEBUG validate_unit_vector(ray.dir);

    divx := 1.0 / ray.dir.x;
    divy := 1.0 / ray.dir.y;

    minx := (aabb.lower.x - ray.p.x) * divx;
    maxx := (aabb.upper.x - ray.p.x) * divx;
    if minx > maxx {
        t := minx;
        minx = maxx;
        maxx = t;
    }

    miny := (aabb.lower.y - ray.p.y) * divy;
    maxy := (aabb.upper.y - ray.p.y) * divy;
    if miny > maxy {
        t := miny;
        miny = maxy;
        maxy = t;
    }

    minv := max(minx, miny);
    maxv := min(maxx, maxy);

    return maxv >= 0 && maxv >= minv;
}

intersects :: (aabb: AABB3, ray: Ray3) -> bool {
    #if DEBUG validate_unit_vector(ray.dir);

    divx := 1.0 / ray.dir.x;
    divy := 1.0 / ray.dir.y;
    divz := 1.0 / ray.dir.z;

    minx := (aabb.lower.x - ray.p.x) * divx;
    maxx := (aabb.upper.x - ray.p.x) * divx;
    if minx > maxx {
        t := minx;
        minx = maxx;
        maxx = t;
    }

    miny := (aabb.lower.y - ray.p.y) * divy;
    maxy := (aabb.upper.y - ray.p.y) * divy;
    if miny > maxy {
        t := miny;
        miny = maxy;
        maxy = t;
    }

    minz := (aabb.lower.z - ray.p.z) * divz;
    maxz := (aabb.upper.z - ray.p.z) * divz;
    if minz > maxz {
        t := minz;
        minz = maxz;
        maxz = t;
    }

    minv := max(max(minx, miny), minz);
    maxv := min(min(maxx, maxy), maxz);

    return maxv >= 0 && maxv >= minv;
}

merge :: (a: AABB2, b: AABB2) -> AABB2 {
    // TODO simd
    aabb: AABB2 = ---;
    aabb.lower = min(a.lower, b.lower);
    aabb.upper = max(a.upper, b.upper);
    return aabb;
}

merge :: (a: AABB3, b: AABB3) -> AABB3 {
    // TODO simd
    aabb: AABB3 = ---;
    aabb.lower = min(a.lower, b.lower);
    aabb.upper = max(a.upper, b.upper);
    return aabb;
}

contains :: (outer: AABB3, inner: AABB3) -> bool {
    result := false;
    result = result && outer.lower.x <= inner.lower.x;
    result = result && outer.lower.y <= inner.lower.y;
    result = result && outer.lower.z <= inner.lower.z;
    result = result && inner.upper.x <= outer.upper.x;
    result = result && inner.upper.y <= outer.upper.y;
    result = result && inner.upper.z <= outer.upper.z;

    return result;
}

contains :: (outer: AABB2, inner: AABB2) -> bool {
    result := false;
    result = result && outer.lower.x <= inner.lower.x;
    result = result && outer.lower.y <= inner.lower.y;
    result = result && inner.upper.x <= outer.upper.x;
    result = result && inner.upper.y <= outer.upper.y;

    return result;
}

contains :: (aabb: AABB3, point: Vector3) -> bool {
    return point.x >= aabb.lower.x && point.y >= aabb.lower.y && point.z >= aabb.lower.z && point.x < aabb.upper.x && point.y < aabb.upper.y && point.z < aabb.upper.z;
}

contains :: (aabb: AABB2, point: Vector2) -> bool {
    return point.x >= aabb.lower.x && point.y >= aabb.lower.y && point.x < aabb.upper.x && point.y < aabb.upper.y;
}

round :: (aabb: AABB2) -> AABB2 {
    r: AABB2 = ---;
    r.lower = round(aabb.lower);
    r.upper = round(aabb.upper);
    return r;
}

get_center :: (aabb: AABB3) -> Vector3 {
    return aabb.lower / 2.0 + aabb.upper / 2.0;
}

get_radius :: (aabb: AABB3) -> float {
    center := get_center(aabb);

    aabb_points: [8] Vector3 = ---;
    aabb_points[0] = Vector3.{aabb.lower.x, aabb.lower.y, aabb.lower.z};
    aabb_points[1] = Vector3.{aabb.lower.x, aabb.lower.y, aabb.upper.z};
    aabb_points[2] = Vector3.{aabb.lower.x, aabb.upper.y, aabb.lower.z};
    aabb_points[3] = Vector3.{aabb.lower.x, aabb.upper.y, aabb.upper.z};
    aabb_points[4] = Vector3.{aabb.upper.x, aabb.lower.y, aabb.lower.z};
    aabb_points[5] = Vector3.{aabb.upper.x, aabb.lower.y, aabb.upper.z};
    aabb_points[6] = Vector3.{aabb.upper.x, aabb.upper.y, aabb.lower.z};
    aabb_points[7] = Vector3.{aabb.upper.x, aabb.upper.y, aabb.upper.z};

    max_r2 := 0.0;
    for point: aabb_points {
        max_r2 = max(max_r2, distance_squared(center, point));
    }

    return sqrt(max_r2);
}

operator == :: (a: AABB2, b: AABB2) -> bool {
    return a.lower == b.lower && a.upper == b.upper;
}

operator == :: (a: AABB3, b: AABB3) -> bool {
    return a.lower == b.lower && a.upper == b.upper;
}

operator + :: (aabb: AABB2, v: Vector2) -> AABB2 #symmetric {
    r: AABB2 = ---;
    r.lower = aabb.lower + v;
    r.upper = aabb.upper + v;
    return r;
}

operator + :: (aabb: AABB3, v: Vector3) -> AABB3 #symmetric {
    r: AABB3 = ---;
    r.lower = aabb.lower + v;
    r.upper = aabb.upper + v;
    return r;
}

// gonna really have to do template stuff with this to make it not such a huge mess
operator - :: (aabb: AABB2, v: Vector2) -> AABB2 {
    r: AABB2 = ---;
    r.lower = aabb.lower - v;
    r.upper = aabb.upper - v;
    return r;
}

operator - :: (aabb: AABB3, v: Vector3) -> AABB3 {
    r: AABB3 = ---;
    r.lower = aabb.lower - v;
    r.upper = aabb.upper - v;
    return r;
}

operator - :: (v: Vector2, aabb: AABB2) -> AABB2 {
    r: AABB2 = ---;
    r.lower = v - aabb.lower;
    r.upper = v - aabb.upper;
    return r;
}

operator - :: (v: Vector3, aabb: AABB3) -> AABB3 {
    r: AABB3 = ---;
    r.lower = v - aabb.lower;
    r.upper = v - aabb.upper;
    return r;
}

// quad stuff
is_convex :: (a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool {
    // p61
    // Quad is nonconvex if Dot(Cross(bd, ba), Cross(bd, bc)) >= 0
    bda := cross(d - b, a - b);
    bdc := cross(d - b, c - b);
    if dot(bda, bdc) >= 0 return false;
    // Quad is now convex iff Dot(Cross(ac, ad), Cross(ac, ab)) < 0
    acd := cross(c - a, d - a);
    acb := cross(c - a, b - a);

    return dot(acd, acb) < 0;
}

// triangle stuff
operator == :: (a: Triangle3, b: Triangle3) -> bool {
    return a.a == b.a && a.b == b.b && a.c == b.c;    
}

get_normal :: (triangle: Triangle3) -> Vector3 {
    return normalize(cross(triangle.b - triangle.a, triangle.c - triangle.a));
}

intersection :: (triangle: Triangle3, ray: Ray3) -> Vector3, Vector3, bool {
    #if DEBUG validate_unit_vector(ray.dir);

    p := ray.p;
    q := ray.p + ray.dir;

    using triangle;

    ab := b - a;
    ac := c - a;
    qp := p - q;

    n := cross(ab, ac);

    d := dot(qp, n);
    if d < 0 {
        return .{}, .{}, false;
    }

    ap := p - a;
    t := dot(ap, n);
    if t < 0 {
        return .{}, .{}, false;
    }

    e := cross(qp, ap);
    v := dot(ac, e);
    if v < 0 || v > d {
        return .{}, .{}, false;
    }
    w := -dot(ab, e);
    if w < 0 || v + w > d {
        return .{}, .{}, false;
    }

    ood := 1.0 / d;
    t *= ood;
    v *= ood;
    w *= ood;
    u := 1.0 - v - w;
    return ray.p + ray.dir * t, n, true;
}

intersection :: (triangle: Triangle3, line: Line3) -> Vector3, bool {
    using triangle;

    p := line.p1;
    q := line.p2;

    pq := q - p;
    pa := a - p;
    pb := b - p;
    pc := c - p;

    // test if pq is inside edges bc, ca, ab
    m := cross(pq, pc);

    u := dot(pb, m);
    if u < 0 return .{}, false;

    v := -dot(pa, m);
    if v < 0 return .{}, false;

    w := scalar_triple(pq, pb, pa);
    if w < 0 return .{}, false;

    denom := 1.0 / (u + v + w);

    u *= denom;
    v *= denom;
    w *= denom;

    return u * a + v * b + w * c, true;
}

intersects :: (triangle: Triangle3, point: Vector3) -> bool {
    // p204
    // Translate point and triangle so that point lies at origin
    a := triangle.a - point;
    b := triangle.b - point;
    c := triangle.c - point;
    ab := dot(a, b);
    ac := dot(a, c);
    bc := dot(b, c);
    cc := dot(c, c);
    // Make sure plane normals for pab and pbc point in the same direction
    if bc * ac - cc * ab < 0 return false;
    // Make sure plane normals for pab and pca point in the same direction
    bb := dot(b, b);
    if ab * bc - ac * bb < 0 return false;
    // Otherwise P must be in (or on) the triangle
    return true;
}

intersects :: (triangle: Triangle2, point: Vector2) -> bool {
    // p206
    // Test if 2D point P lies inside 2D triangle ABC
    // If P to the right of AB then outside triangle
    if cross(point - triangle.a, triangle.b - triangle.a) > 0 return false;
    // If P to the right of BC then outside triangle
    if cross(point - triangle.b, triangle.c - triangle.b) > 0 return false;
    // If P to the right of CA then outside triangle
    if cross(point - triangle.c, triangle.a - triangle.c) > 0 return false;
    // Otherwise P must be in (or on) the triangle
    return true;
}

nearest_point :: (triangle: Triangle2, point: Vector2) -> Vector2 {
    // TODO dont know if this is right bc nothing had to change from the 3d version
    // p141
    // Check if P in vertex region outside A
    ab := triangle.b - triangle.a;
    ac := triangle.c - triangle.a;
    ap := point - triangle.a;
    d1 := dot(ab, ap);
    d2 := dot(ac, ap);
    if d1 <= 0 && d2 <= 0 {
        return triangle.a; // barycentric coordinates (1,0,0)
    }
    // Check if P in vertex region outside B
    bp := point - triangle.b;
    d3 := dot(ab, bp);
    d4 := dot(ac, bp);
    if d3 >= 0 && d4 <= d3 {
        return triangle.b; // barycentric coordinates (0,1,0)
    }
    // Check if P in edge region of AB, if so return projection of P onto AB
    vc := d1 * d4 - d3 * d2;
    if vc <= 0 && d1 >= 0 && d3 <= 0 {
        v := d1 / (d1 - d3);
        return triangle.a + v * ab; // barycentric coordinates (1-v,v,0)
    }
    // Check if P in vertex region outside C
    cp := point - triangle.c;
    d5 := dot(ab, cp);
    d6 := dot(ac, cp);
    if d6 >= 0 && d5 <= d6 {
        return triangle.c; // barycentric coordinates (0,0,1)
    }
    // Check if P in edge region of AC, if so return projection of P onto AC
    vb := d5 * d2 - d1 * d6;
    if vb <= 0 && d2 >= 0 && d6 <= 0 {
        w := d2 / (d2 - d6);
        return triangle.a + w * ac; // barycentric coordinates (1-w,0,w)
    }
    // Check if P in edge region of BC, if so return projection of P onto BC
    va := d3 * d6 - d5 * d4;
    if va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0 {
        w := (d4 - d3) / ((d4 - d3) + (d5 - d6));
        return triangle.b + w * (triangle.c - triangle.b); // barycentric coordinates (0,1-w,w)
    }
    // P inside face region. Compute Q through its barycentric coordinates (u,v,w)
    denom := 1 / (va + vb + vc);
    v := vb * denom;
    w := vc * denom;
    return triangle.a + ab * v + ac * w; // = u*a + v*b + w*c, u = va * denom = 1-v-w
}

nearest_point :: (triangle: Triangle3, point: Vector3) -> Vector3 {
    // p141
    // Check if P in vertex region outside A
    ab := triangle.b - triangle.a;
    ac := triangle.c - triangle.a;
    ap := point - triangle.a;
    d1 := dot(ab, ap);
    d2 := dot(ac, ap);
    if d1 <= 0 && d2 <= 0 {
        return triangle.a; // barycentric coordinates (1,0,0)
    }
    // Check if P in vertex region outside B
    bp := point - triangle.b;
    d3 := dot(ab, bp);
    d4 := dot(ac, bp);
    if d3 >= 0 && d4 <= d3 {
        return triangle.b; // barycentric coordinates (0,1,0)
    }
    // Check if P in edge region of AB, if so return projection of P onto AB
    vc := d1 * d4 - d3 * d2;
    if vc <= 0 && d1 >= 0 && d3 <= 0 {
        v := d1 / (d1 - d3);
        return triangle.a + v * ab; // barycentric coordinates (1-v,v,0)
    }
    // Check if P in vertex region outside C
    cp := point - triangle.c;
    d5 := dot(ab, cp);
    d6 := dot(ac, cp);
    if d6 >= 0 && d5 <= d6 {
        return triangle.c; // barycentric coordinates (0,0,1)
    }
    // Check if P in edge region of AC, if so return projection of P onto AC
    vb := d5 * d2 - d1 * d6;
    if vb <= 0 && d2 >= 0 && d6 <= 0 {
        w := d2 / (d2 - d6);
        return triangle.a + w * ac; // barycentric coordinates (1-w,0,w)
    }
    // Check if P in edge region of BC, if so return projection of P onto BC
    va := d3 * d6 - d5 * d4;
    if va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0 {
        w := (d4 - d3) / ((d4 - d3) + (d5 - d6));
        return triangle.b + w * (triangle.c - triangle.b); // barycentric coordinates (0,1-w,w)
    }
    // P inside face region. Compute Q through its barycentric coordinates (u,v,w)
    denom := 1 / (va + vb + vc);
    v := vb * denom;
    w := vc * denom;
    return triangle.a + ab * v + ac * w; // = u*a + v*b + w*c, u = va * denom = 1-v-w
}

area :: (triangle: Triangle3) -> float {
    return length(cross(triangle.c - triangle.a, triangle.c - triangle.b)) / 2.0;
}

area_signed :: (triangle: Triangle2) -> float {
    // p152
    return ((triangle.a.x - triangle.c.x) * (triangle.b.y - triangle.c.y) - (triangle.a.y - triangle.c.y) * (triangle.b.x - triangle.c.x)) / 2.0;
}

is_ccw :: (triangle: Triangle2) -> bool {
    return area_signed(triangle) < 0;
}

// ray stuff
// ray.dir must be a unit vector
// returns signed distance from the point to the ray

nearest_point :: (ray1: Ray3, ray2: Ray3) -> Vector3, Vector3 {
    #if DEBUG validate_unit_vector(ray1.dir);
    #if DEBUG validate_unit_vector(ray2.dir);

    p1 := ray1.p;
    d1 := ray1.dir;
    p2 := ray2.p;
    d2 := ray2.dir;
    r := ray1.p - ray2.p;

    a := dot(d1, d1);
    b := dot(d1, d2);
    c := dot(d1, r);
    e := dot(d2, d2);
    f := dot(d2, r);

    denom := a * e - b * b;
    s := 0.0;
    if abs(denom) >= EPSILON {
        s = (b * f - c * e) / denom;
    }

    // compute point on ray2
    t := (b * s + f) / e;

    result1 := ray1.p + ray1.dir * s;
    result2 := ray2.p + ray2.dir * t;
    return result1, result2;
}

nearest_point :: (ray: Ray3, point: Vector3) -> Vector3, float {
    #if DEBUG validate_unit_vector(ray.dir);

    // p128
    t := dot(point - ray.p, ray.dir) / dot(ray.dir, ray.dir);

    return ray.p + t * ray.dir, t;
}

distance :: (ray: Ray2, point: Vector2) -> float {
    #if DEBUG validate_unit_vector(ray.dir);
    
    a := ray.p;
    b := ray.p + ray.dir;
    c := point;

    ab := b - a;
    ac := c - a;
    e := dot(ac, ab);
    f := dot(ab, ab);

    signed := sign(cross(ray.dir, point - ray.p));

    return sqrt(dot(ac, ac) - e * e / f) * signed;
}

// distance :: (ray: Ray2, point: Vector2) -> float {
//     // real time collision, p127
//     #if DEBUG validate_unit_vector(ray.dir);

//     d := ray.dir.x * ray.dir.x + ray.dir.y * ray.dir.y;
//     return ray.dir.x * point.x + ray.dir.y * point.y - d;
// }

distance :: (ray: Ray3, point: Vector3) -> float {
    // real time collision, p127
    #if DEBUG validate_unit_vector(ray.dir);

    return length(nearest_point(ray, point) - point);

    // d := ray.dir.x * ray.dir.x + ray.dir.y * ray.dir.y + ray.dir.z * ray.dir.z;
    // return ray.dir.x * point.x + ray.dir.y * point.y + ray.dir.z * point.z - d;
}

// TODO should really rename all of these to project
nearest_point :: (ray: Ray2, point: Vector2) -> Vector2, float {
    t := dot(point - ray.p, ray.dir) / dot(ray.dir, ray.dir);
    return t * ray.dir + ray.p, t;
}

// line stuff
nearest_point :: (line: Line3, ray: Ray3) -> Vector3 {
    #if DEBUG validate_unit_vector(ray.dir);

    line_ray := Ray3.{line.p1, normalize(line.p2 - line.p1)};

    line_ray_nearest := nearest_point(line_ray, ray);

    return nearest_point(line, line_ray_nearest);
}

nearest_point :: (line1: Line3, line2: Line3) -> p1: Vector3, p2: Vector3, t1: float, t2: float, d: float {
    p1 := line1.p1;
    q1 := line1.p2;
    p2 := line2.p1;
    q2 := line2.p2;

    d1: Vector3 = q1 - p1; // Direction vector of segment S1
    d2: Vector3 = q2 - p2; // Direction vector of segment S2
    r: Vector3 = p1 - p2;
    a: float = dot(d1, d1); // Squared length of segment S1, always nonnegative
    e: float = dot(d2, d2); // Squared length of segment S2, always nonnegative
    f: float = dot(d2, r);

    s: float;
    t: float;
    c1: Vector3;
    c2: Vector3;
    
    // Check if either or both segments degenerate into points
    if a <= EPSILON && e <= EPSILON {
        // Both segments degenerate into points
        s = 0.0;
        t = 0.0;
        c1 = p1;
        c2 = p2;

        return c1, c2, 0, 0, dot(c1 - c2, c1 - c2);
    } else if a <= EPSILON {
        // First segment degenerates into a point
        s = 0.0;
        t = f / e; // s = 0 => t = (b*s + f) / e = f / e
        t = clamp(t, 0.0, 1.0);
    } else if e <= EPSILON {
        c: float = dot(d1, r);
        // Second segment degenerates into a point
        t = 0.0;
        // t = 0 => s = (b*t - c) / a = -c / a
        s = clamp(-c / a, 0.0, 1.0); 
    } else {
        c: float = dot(d1, r);
        // The general nondegenerate case starts here
        b: float = dot(d1, d2);
        denom: float = a * e - b * b; // Always nonnegative
        // If segments not parallel, compute closest point on L1 to L2 and
        // clamp to segment S1. Else pick arbitrary s (here 0)
        if denom != 0.0 {
            s = clamp((b * f - c * e) / denom, 0.0, 1.0);
        } else {
            s = 0.0;
        }
        // Compute point on L2 closest to S1(s) using
        // t = Dot((P1 + D1*s) - P2,D2) / Dot(D2,D2) = (b*s + f) / e
        t = (b * s + f) / e;
        // If t in [0,1] done. Else clamp t, recompute s for the new value
        // of t using s = Dot((P2 + D2*t) - P1,D1) / Dot(D1,D1)= (t*b - c) / a
        // and clamp s to [0, 1]
        if t < 0.0 {
            t = 0.0;
            s = clamp(-c / a, 0.0, 1.0);
        } else if t > 1.0 {
            t = 1.0;
            s = clamp((b - c) / a, 0.0, 1.0);
        }
    }

    c1 = p1 + d1 * s;
    c2 = p2 + d2 * t;
    return c1, c2, s, t, dot(c1 - c2, c1 - c2);
}

// I put #must here to be sure anything using this breaks since I'm adding more floats
nearest_point :: (line1: Line2, line2: Line2) -> p1: Vector2, p2: Vector2, t1: float, t2: float, d: float {
    p1 := line1.p1;
    q1 := line1.p2;
    p2 := line2.p1;
    q2 := line2.p2;

    d1: Vector2 = q1 - p1; // Direction vector of segment S1
    d2: Vector2 = q2 - p2; // Direction vector of segment S2
    r: Vector2 = p1 - p2;
    a: float = dot(d1, d1); // Squared length of segment S1, always nonnegative
    e: float = dot(d2, d2); // Squared length of segment S2, always nonnegative
    f: float = dot(d2, r);

    s: float;
    t: float;
    c1: Vector2;
    c2: Vector2;
    
    // Check if either or both segments degenerate into points
    if a <= EPSILON && e <= EPSILON {
        // Both segments degenerate into points
        s = 0.0;
        t = 0.0;
        c1 = p1;
        c2 = p2;

        return c1, c2, 0, 0, dot(c1 - c2, c1 - c2);
    }

    if a <= EPSILON {
        // First segment degenerates into a point
        s = 0.0;
        t = f / e; // s = 0 => t = (b*s + f) / e = f / e
        t = clamp(t, 0.0, 1.0);
    } else if e <= EPSILON {
        c: float = dot(d1, r);
        // Second segment degenerates into a point
        t = 0.0;
        // t = 0 => s = (b*t - c) / a = -c / a
        s = clamp(-c / a, 0.0, 1.0); 
    } else {
        c: float = dot(d1, r);
        // The general nondegenerate case starts here
        b: float = dot(d1, d2);
        denom: float = a * e - b * b; // Always nonnegative
        // If segments not parallel, compute closest point on L1 to L2 and
        // clamp to segment S1. Else pick arbitrary s (here 0)
        if denom != 0.0 {
            s = clamp((b * f - c * e) / denom, 0.0, 1.0);
        } else {
            s = 0.0;
        }
        // Compute point on L2 closest to S1(s) using
        // t = Dot((P1 + D1*s) - P2,D2) / Dot(D2,D2) = (b*s + f) / e
        t = (b * s + f) / e;
        // If t in [0,1] done. Else clamp t, recompute s for the new value
        // of t using s = Dot((P2 + D2*t) - P1,D1) / Dot(D1,D1)= (t*b - c) / a
        // and clamp s to [0, 1]
        if t < 0.0 {
            t = 0.0;
            s = clamp(-c / a, 0.0, 1.0);
        } else if t > 1.0 {
            t = 1.0;
            s = clamp((b - c) / a, 0.0, 1.0);
        }
    }

    c1 = p1 + d1 * s;
    c2 = p2 + d2 * t;
    return c1, c2, s, t, dot(c1 - c2, c1 - c2);
}

intersection :: (line1: Line2, line2: Line2) -> Vector2, bool {
    t: float = 0;
    vector, value := intersection(line1, line2, *t);
    return vector, value;
}

// returns t along line1 of the intersection
intersection :: (line1: Line2, line2: Line2, t: *float) -> Vector2, bool {
    // p152
    // Sign of areas correspond to which side of ab points c and d are
    abd: Triangle2 = ---;
    abd.a = line1.p1;
    abd.b = line1.p2;
    abd.c = line2.p2;

    abc: Triangle2 = ---;
    abc.a = line1.p1;
    abc.b = line1.p2;
    abc.c = line2.p1;

    a1 := area_signed(abd) * 2.0; // Compute winding of abd (+ or -)
    a2 := area_signed(abc) * 2.0; // To intersect, must have sign opposite of a1

    // If c and d are on different sides of ab, areas have different signs
    if a1 * a2 < 0 {
        // Compute signs for a and b with respect to segment cd
        cda: Triangle2 = ---;
        cda.a = line2.p1;
        cda.b = line2.p2;
        cda.c = line1.p1;

        a3 := area_signed(cda) * 2.0; // Compute winding of cda (+ or -)
        // Since area is constant a1 - a2 = a3 - a4, or a4 = a3 + a2 - a1
        // float a4 = Signed2DTriArea(c, d, b); // Must have opposite sign of a3
        a4 := a3 + a2 - a1;
        // Points a and b on different sides of cd if areas have different signs
        if a3 * a4 < 0 {
            // Segments intersect. Find intersection point along L(t) = a + t * (b - a).
            // Given height h1 of an over cd and height h2 of b over cd,
            // t = h1 / (h1 - h2) = (b*h1/2) / (b*h1/2 - b*h2/2) = a3 / (a3 - a4),
            // where b (the base of the triangles cda and cdb, i.e., the length
            // of cd) cancels out.
            << t = a3 / (a3 - a4);
            point := line1.p1 + << t * (line1.p2 - line1.p1);

            return point, true;
        }
    }

    // Segments not intersecting (or collinear)
    return .{0, 0}, false;
}

nearest_point :: (line: Line2, point: Vector2) -> Vector2, float {
    // p128
    ab := line.p2 - line.p1;
    abdot := dot(ab, ab);
    if abdot < EPSILON {
        return line.p1, 0;
    }
    
    t := dot(point - line.p1, ab) / abdot;
    if t < 0.0 {
        t = 0.0;
    }
    if t > 1.0 {
        t = 1.0;
    }

    return line.p1 + t * ab, t;
}

nearest_point :: (line: Line3, point: Vector3) -> Vector3, float {
    // p128
    ab := line.p2 - line.p1;
    abdot := dot(ab, ab);
    if abdot < EPSILON {
        return line.p1, 0;
    }
    
    t := dot(point - line.p1, ab) / abdot;
    if t < 0.0 {
        t = 0.0;
    }
    if t > 1.0 {
        t = 1.0;
    }

    return line.p1 + t * ab, t;
}

distance :: (line: Line2, point: Vector2) -> float {
    return sqrt(distance_squared(line, point));
}

distance :: (line: Line3, point: Vector3) -> float {
    return sqrt(distance_squared(line, point));
}

distance_squared :: (line: Line2, point: Vector2) -> float {
    // p130
    ab := line.p2 - line.p1;
    ac := point - line.p1;
    bc := point - line.p2;
    
    e := dot(ac, ab);
    if e <= 0 {
        return dot(ac, ac);
    }

    f := dot(ab, ab);
    if e >= f {
        return dot(bc, bc);
    }

    return dot(ac, ac) - e * e / f;
}

distance_squared :: (line: Line3, point: Vector3) -> float {
    // p130
    ab := line.p2 - line.p1;
    ac := point - line.p1;
    bc := point - line.p2;
    
    e := dot(ac, ab);
    if e <= 0 {
        return dot(ac, ac);
    }

    f := dot(ab, ab);
    if e >= f {
        return dot(bc, bc);
    }

    return dot(ac, ac) - e * e / f;
}

// array stuff
reverse :: (v: [] $T) {
    for i: 0..v.count / 2 - 1 {
        p1, p2 := swap(v.data[i], v.data[v.count - i - 1]);
        v.data[i] = p1;
        v.data[v.count - i - 1] = p2;
    }
}

// frustum stuff
// creates a frustum that allows any object to be rendered infinitely into the distance
create_camera_frustum :: (projection: Matrix4, view: Matrix4, $clip_far_plane_only: bool = false) -> Frustum {
    inverse_projection := inverse(projection);
    inverse_view := inverse(view);
    clip := projection * view;
    inverse_clip := inverse_view * inverse_projection;

    camera_point := transform_point(inverse_view, .{0, 0, 0});

    points := Vector4.[
        inverse_clip * Vector4.{0, 0, -1, 1},
        inverse_clip * Vector4.{-1, 0, -1, 1},
        inverse_clip * Vector4.{1, 0, -1, 1},
        inverse_clip * Vector4.{0, -1, -1, 1},
        inverse_clip * Vector4.{0, 1, -1, 1},
    ];
    for *point: points {
        if point.w != 0 {
            point.xyz /= point.w;
        }
    }

    frustum: Frustum;
    frustum.point = camera_point;

    // forward
    frustum.normals[0] = clip.v[3] + clip.v[2];
    // left
    frustum.normals[1] = clip.v[3] + clip.v[0];
    // right
    frustum.normals[2] = clip.v[3] - clip.v[0];
    // bottom
    frustum.normals[3] = clip.v[3] + clip.v[1];
    // top
    frustum.normals[4] = clip.v[3] - clip.v[1];

    for i: 0..frustum.normals.count - 1 {
        frustum.normals[i].xyz = normalize(frustum.normals[i].xyz);
    }

    frustum.normals[0].w = dot(points[0].xyz, frustum.normals[0].xyz);
    frustum.normals[1].w = dot(points[1].xyz, frustum.normals[1].xyz);
    frustum.normals[2].w = dot(points[2].xyz, frustum.normals[2].xyz);
    frustum.normals[3].w = dot(points[3].xyz, frustum.normals[3].xyz);
    frustum.normals[4].w = dot(points[4].xyz, frustum.normals[4].xyz);

    #if clip_far_plane_only {
        far_point := inverse_clip * Vector4.{0, 0, 1, 1};
        if far_point.w != 0 {
            far_point.xyz /= far_point.w;
        }

        frustum.normals[0].xyz = -frustum.normals[0].xyz;
        frustum.normals[0].w = dot(far_point.xyz, frustum.normals[0].xyz);
    }

    return frustum;
}

// creates a frustum that allows any object to be rendered behind it, useful for shadows
create_near_camera_frustum :: (projection: Matrix4, view: Matrix4) -> Frustum {
    return create_camera_frustum(projection, view, clip_far_plane_only = true);
}

intersects :: (frustum: Frustum, sphere: Sphere) -> bool {
    return intersects(frustum, sphere.center, sphere.radius);
}

intersects :: (frustum: Frustum, position: Vector3, radius: float) -> bool {
    inside := true;
    for frustum_normal: frustum.normals {
        inside = inside && dot(position, frustum_normal.xyz) - frustum_normal.w >= -radius;
    }

    return inside;
}

intersects :: (frustum: Frustum, local_aabb: AABB3, transform: Matrix4) -> bool {
    // not sure if this is right but I'm extrapolating from aabb overlap
    // check that there is at least 1 point inside each frustum plane
    // or your bounds encompasses the center point

    // return true;

    aabb_points := get_aabb_points(local_aabb);
    for i: 0..aabb_points.count - 1 {
        aabb_points[i] = transform_point(transform, aabb_points[i]);
    }

    // it doesn't interesct if one side has all points on it
    for i: 0..frustum.normals.count - 1 {
        for point: aabb_points {
            if dot(point, frustum.normals[i].xyz) - frustum.normals[i].w >= 0 {
                continue i;
            }
        }

        return false;
    }

    return true;
}

intersects :: (frustum: Frustum, aabb: AABB3) -> bool {
    // not sure if this is right but I'm extrapolating from aabb overlap
    // check that there is at least 1 point inside each frustum plane
    // or your bounds encompasses the center point

    // return true;

    aabb_points := get_aabb_points(aabb);

    // it doesn't interesct if one side has all points on it
    for i: 0..frustum.normals.count - 1 {
        // if i == 0 || i == 1 || i == 3 || i == 4 {
        //     continue;
        // }
        
        for point: aabb_points {
            if dot(point, frustum.normals[i].xyz) - frustum.normals[i].w >= 0 {
                continue i;
            }
        }

        return false;
    }

    return true;
}

// matrix stuff
make_translation_matrix3 :: (v: Vector2) -> Matrix3 #must {
    m := Matrix3Identity;

    m._13 = v.x;
    m._23 = v.y;

    return m;
}

translate :: (m: Matrix3, v: Vector2) -> Matrix3 #must {
    result := m;
    inline translate(*result, v);
    return result;
}

translate :: (m: *Matrix3, v: Vector2) {
    m.coef[0][2] += m.coef[0][0] * v.x + m.coef[0][1] * v.y;
    m.coef[1][2] += m.coef[1][0] * v.x + m.coef[1][1] * v.y;
    m.coef[2][2] += m.coef[2][0] * v.x + m.coef[2][1] * v.y;
}

transform_point :: (m: Matrix3, v: Vector2) -> Vector2 {
    result: Vector2 = ---;
    result.x = m._11 * v.x + m._12 * v.y + m._13;
    result.y = m._21 * v.x + m._22 * v.y + m._23;
    return result;
}

get_scale :: (mat: Matrix4) -> Vector3 {
    column := mat.v[0];

    if column.w == 0 {
        return .{1, 1, 1};
    } else {
        scale := column.xyz;
        scale /= column.w;
        return scale;
    }
}

get_translation :: (matrix: Matrix4) -> Vector3 {
    return Vector3.{matrix._14, matrix._24, matrix._34};
}

decompose_matrix4 :: (matrix: Matrix4) -> Vector3, Quaternion, Vector3 {
    translation := Vector3.{matrix._14, matrix._24, matrix._34};

    scale := Vector3.{
        length(Vector3.{matrix._11, matrix._21, matrix._31}),
        length(Vector3.{matrix._12, matrix._22, matrix._32}),
        length(Vector3.{matrix._13, matrix._23, matrix._33}),
    };

    rotation_matrix := Matrix3.{
        matrix._11 / scale.x, matrix._12 / scale.y, matrix._13 / scale.z,
        matrix._21 / scale.x, matrix._22 / scale.y, matrix._23 / scale.z,
        matrix._31 / scale.x, matrix._32 / scale.y, matrix._33 / scale.z,
    };
    rotation := get_rotation(rotation_matrix);

    return translation, rotation, scale;
}

// quaternion stuff
// quat stuff
make_rotation_quaternion :: (axis: Vector3, radians: float) -> Quaternion {
    d := length(axis);
    if d == 0 return Quaternion.{0, 0, 0, 1};

    d = 1.0 / d;
    l_ang := ifx radians < 0 then PI_2 - (fmod_cycling(-radians, PI_2)) else fmod_cycling(radians, PI_2);
    l_sin := sin(l_ang / 2);
    l_cos := cos(l_ang / 2);
    return normalize(Quaternion.{d * axis.x * l_sin, d * axis.y * l_sin, d * axis.z * l_sin, l_cos});
}

make_rotation_quaternion :: (axis: Vector3_64, radians: float64) -> Quaternion {
    PI_2_64 :: 3.141592653589793238462643383279;
    d := length(axis);
    if d == 0 return Quaternion.{0, 0, 0, 1};

    d = 1.0 / d;
    l_ang := ifx radians < 0 then PI_2_64 - (fmod_cycling(-radians, PI_2_64)) else fmod_cycling(radians, PI_2_64);
    l_sin := sin(l_ang / 2);
    l_cos := cos(l_ang / 2);
    return normalize(Quaternion.{cast(float) (d * axis.x * l_sin), cast(float) (d * axis.y * l_sin), cast(float) (d * axis.z * l_sin), cast(float) l_cos});
}

make_rotation_quaternion :: (velocity: Vector3) -> Quaternion {
    yaw := atan2(velocity.x, velocity.z) + PI;
    rotation_yaw := make_rotation_quaternion(.{0, 1, 0}, yaw);

    pitch := atan2(velocity.y, length(Vector2.{velocity.x, velocity.z}));
    rotation_pitch := make_rotation_quaternion(.{1, 0, 0}, pitch);

    return rotation_yaw * rotation_pitch;
}

decompose_twist_and_swing :: (quat: Quaternion, axis: Vector3) -> Quaternion, Quaternion {
    // not really tested

    // returns the twist, radians around the axis
    // and the swing, radians around the perpendicular axis
    // quaternion can be composed back into itself via swing * twist

    ra := Vector3.{quat.x, quat.y, quat.z}; // rotation axis
    p := project(axis, ra);
    twist := normalize(Quaternion.{p.x, p.y, p.z, quat.w});
    swing := quat * conjugate(twist);
    return twist, swing;
}

get_rotation_around_axis :: (quat: Quaternion, axis: Vector3) -> float {
    // WARNING I CHOSE THE +Y AND -Z ARBITRARILY WITHOUT TESTING IF THEY'RE CONSISTENT
    world_up: Vector3;
    if abs(dot(axis, .{0, 1, 0})) < abs(dot(axis, .{0, 0, -1})) {
        world_up = .{0, 1, 0};
    } else {
        world_up = .{0, 0, -1};
    }
    forward := cross(world_up, axis);
    up := cross(axis, forward);

    quat_vector := rotate(.{0, 0, -1}, quat);

    return atan2(dot(quat_vector, up), dot(quat_vector, forward));
}

normalize :: (using quat: Quaternion) -> Quaternion {
    sq := sqrt(x * x + y * y + z * z + w * w);
    if sq == 0 {
        return quat;
    }

    factor := 1.0 / sq;
    return Quaternion.{x * factor, y * factor, z * factor, w * factor};
}

quat_radians_between :: (qa: Quaternion, qb: Quaternion) -> float {
    cos_half_theta := qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;

    if cos_half_theta < 0 {
        cos_half_theta = -cos_half_theta;
    }

    radians := acos(cos_half_theta);
    return radians;
}

quat_slerp :: (qa: Quaternion, qb1: Quaternion, t: float) -> Quaternion {
    qb := qb1;

    qm: Quaternion;

    cos_half_theta := qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;

    if cos_half_theta < 0 {
        qb.w = -qb.w;
        qb.x = -qb.x;
        qb.y = -qb.y;
        qb.z = -qb.z;
        cos_half_theta = -cos_half_theta;
    }

	// if qa=qb or qa=-qb then theta = 0 and we can return qa
	if abs(cos_half_theta) >= 1.0 {
		qm.w = qa.w;
        qm.x = qa.x;
        qm.y = qa.y;
        qm.z = qa.z;
		return qm;
	}

	half_theta := acos(cos_half_theta);
	sin_half_theta := sqrt(1.0 - cos_half_theta * cos_half_theta);

    // if theta = 180 degrees then result is not fully defined
	// we could rotate around any axis normal to qa or qb
	if abs(sin_half_theta) < 0.001 {
		qm.w = (qa.w * 0.5 + qb.w * 0.5);
		qm.x = (qa.x * 0.5 + qb.x * 0.5);
		qm.y = (qa.y * 0.5 + qb.y * 0.5);
		qm.z = (qa.z * 0.5 + qb.z * 0.5);
		return qm;
	}
	ratio_a := sin((1 - t) * half_theta) / sin_half_theta;
	ratio_b := sin(t * half_theta) / sin_half_theta; 
    
	qm.w = (qa.w * ratio_a + qb.w * ratio_b);
	qm.x = (qa.x * ratio_a + qb.x * ratio_b);
	qm.y = (qa.y * ratio_a + qb.y * ratio_b);
	qm.z = (qa.z * ratio_a + qb.z * ratio_b);
	return qm;
}

// vector stuff
project :: (dest: $T/AnyVector3, src: T) -> T {
    return (dot(src, dest) / dot(dest, dest)) * dest;
}

project :: (dest: Vector2, src: Vector2) -> Vector2 {
    return (dot(src, dest) / dot(dest, dest)) * dest;
}

project_direction :: (normal: Vector2, src: Vector2) -> Vector2 {
    dest := Vector2.{normal.y, -normal.x};
    return inline project(dest, src);
}

project_direction :: (normal: Vector3, direction: Vector3) -> Vector3 {
    return direction - dot(normal, direction) * normal;
}

project_direction :: (normal: Vector3_64, direction: Vector3_64) -> Vector3_64 {
    return direction - dot(normal, direction) * normal;
}

length_squared :: (v: Vector3_64) -> float64 {
    return v.x * v.x + v.y * v.y + v.z * v.z;
}

decompose_correct :: (v: Vector3, dir: Vector3) -> v: Vector3 {
    dir_strength := dot(normalize(v), dir);

    return v * dir_strength;
}

decompose :: (v: Vector3, dir: Vector3) -> v: Vector3, v_dir: Vector3 {
    // Decompose seems to produce weird results. Probably math isn't exactly right.
    dir_strength := dot(v, dir);

    v_dir := dir * dir_strength;
    return v - v_dir, v_dir;
}

decompose_signed :: (v: Vector3, dir: Vector3) -> v: Vector3, v_dir: Vector3 {
    // Decompose seems to produce weird results. Probably math isn't exactly right.
    dir_strength := dot(v, dir);
    if dir_strength <= 0 {
        return v, .{};
    }

    v_dir := dir * dir_strength;
    return v - v_dir, v_dir;
}

// projects the direction onto the normal plain but maintains the direction magnitude (if possible)
project_direction_conformal :: (normal: Vector3, direction: Vector3) -> Vector3 {
    projected := project_direction(normal, direction);
    if length_squared(projected) < 0.000001 {
        return .{};
    }
    return normalize(projected) * length(direction);
}

project_multiple_normals :: (v_raw: Vector3, normals: [] Vector3) -> Vector3, modified: bool {
    // the plan is create all permutation of plane vectors that are in the direction of v
    // I think I also have to include the "permutations" of the vector projected onto all normals in case those satisfy it
    // also include the actual vector
    // each plane should have either 1 or 0 vectors that fit this category
    // for each of these pemutations, sort them so that the largest dot product with v is first
    // go through them in order until one permutation satisfies all plane normal requirements
    // return that one
    // if not a single permutation satisfies all planes, return a zero vector

    // the vector itself is the least resistance option
    // then projecting onto single planes is the next least resistance option
    // then finally projecting onto a combination of 2 planes is the most resistance
    // so instead of treating these all as the same thing we can check these cases in order

    mag := length(v_raw);
    v := normalize(v_raw);

    if mag < 0.000001 {
        return v_raw, false;
    }

    validate_projection :: inline (proj: Vector3, normals: [] Vector3) -> bool {
        valid := true;
        for normal: normals {
            valid = valid && dot(proj, normal) >= -0.000001;
        }
        return valid;
    }

    sort_by_largest_dot_product :: (normals: [] Vector3, v: Vector3) {
        for i: 0..normals.count - 1 {
            for a: i + 1..normals.count - 1 {
                if dot(v, normals[i]) < dot(v, normals[a]) {
                    normals[i], normals[a] = normals[a], normals[i];
                }
            }
        }
    }

    // test just the vector
    if validate_projection(v, normals) {
        return v_raw, false;
    }

    // these are the normals to start with, all permutations form from these
    restricting_normal_index := 0;
    restricting_normals := NewArray(normals.count, Vector3,, temp);
    for normal: normals {
        if dot(v, normal) <= 0.000001 {
            restricting_normals[restricting_normal_index] = normal;
            restricting_normal_index += 1;
        }
    }
    restricting_normals.count = restricting_normal_index;

    // this sorts so largest dot product is first
    // so since these are normals we want to look at 0 dot products first
    // the largest possible value is 0 because you're inherently going into these normals
    sort_by_largest_dot_product(restricting_normals, v);

    // so now we check if any are valid, and since they're sorted we just return
    for normal: restricting_normals {
        proj := project_direction(normal, v);
        if validate_projection(proj, normals) {
            return proj * mag, true;
        }
    }

    permutation_count := restricting_normals.count * normals.count;

    permutation_index := 0;
    permutations := NewArray(permutation_count, Vector3,, temp);

    // check n^2 because even if you don't get restricted by index 1, projecting onto index 4 could cause index 1 to start restricting
    // start with vectors that are restricting because we need to immediately project
    for i: 0..restricting_normals.count - 1 {
        proj := project_direction(normals[i], v);

        for a: 0..normals.count - 1 {
            // we only include this permutation if the vector projected onto the restricting normal is also restricted by the other normal
            if dot(proj, normals[a]) > 0 {
                continue;
            }

            permutation := cross(normals[i], normals[a]);

            permutation_dot := dot(permutation, v);
            if permutation_dot > 0.000001 {
                permutations[permutation_index] = permutation;
                permutation_index += 1;
            } else if permutation_dot < -0.000001 {
                permutations[permutation_index] = -permutation;
                permutation_index += 1;
            }
        }
    }
    permutations.count = permutation_index;

    sort_by_largest_dot_product(permutations, v);

    for permutation: permutations {
        if validate_projection(permutation, normals) {
            return dot(v, permutation) / dot(permutation, permutation) * permutation * mag, true;
        }
    }

    return .{}, true;
}

project_multiple_normals_conformal :: (v_raw: Vector3, normals: [] Vector3) -> Vector3, modified: bool {
    proj, modified := project_multiple_normals(v_raw, normals);
    return normalize(proj) * length(v_raw), modified;
}

scalar_triple :: (u: Vector3, v: Vector3, w: Vector3) -> float {
    return dot(cross(u, v), w);
}

// normalize :: (using v: Vector2) -> Vector2 #must {
//     normalize(*v, epsilon, fallback);
//     return v;
// }

// normalize :: (using v: *Vector2) -> float {
//     sq := sqrt(x*x + y*y);
//     if sq == 0.0 {
//         <<v = .{};
//         return sq;
//     }

//     factor := 1.0 / sq;
//     x *= factor;
//     y *= factor;

//     return sq;
// }

inverse_project :: (dest: Vector2, src: Vector2) -> Vector2 {
    // projects src onto dest but makes a right angle with src so that the final result is much larger
    theta := acos(dot(src, dest) / (length(src) * length(dest)));

    projection_length := length(src) / sin(PI / 2 - theta);
    return normalize(dest) * projection_length;
}

rotate :: (vector: Vector3, axis: Vector3, radians: float) -> Vector3 {
    rotation_quaternion: Quaternion;
    set_from_axis_and_angle(*rotation_quaternion, axis, radians);

    return rotate(vector, rotation_quaternion);
}

perp :: (vector: Vector2) -> Vector2 {
    return xy(-vector.y, vector.x);
}

atan2 :: (a: Vector2) -> float {
    return atan2(a.y, a.x);
}

// min :: (a: Vector2, b: Vector2) -> Vector2 {
//     vector: Vector2 = ---;
//     vector.x = min(a.x, b.x);
//     vector.y = min(a.y, b.y);
//     return vector;
// }

// min :: (a: Vector3, b: Vector3) -> Vector3 {
//     vector: Vector3 = ---;
//     vector.x = min(a.x, b.x);
//     vector.y = min(a.y, b.y);
//     vector.z = min(a.z, b.z);
//     return vector;
// }

// max :: (a: Vector2, b: Vector2) -> Vector2 {
//     vector: Vector2 = ---;
//     vector.x = max(a.x, b.x);
//     vector.y = max(a.y, b.y);
//     return vector;
// }

// max :: (a: Vector3, b: Vector3) -> Vector3 {
//     vector: Vector3 = ---;
//     vector.x = max(a.x, b.x);
//     vector.y = max(a.y, b.y);
//     vector.z = max(a.z, b.z);
//     return vector;
// }

cross :: (a: Vector2, b: Vector2) -> float {
    // p205
    return a.y * b.x - a.x * b.y;
}

// returns whether or not vector b is to the right side of vector a
is_right :: (a: Vector2, b: Vector2) -> bool {
    return cross(a, b) > 0;
}

is_left :: (a: Vector2, b: Vector2) -> bool {
    return cross(a, b) < 0;
}

is_forward :: (a: Vector2, b: Vector2) -> bool {
    return dot(a, b) > 0;
}

is_backward :: (a: Vector2, b: Vector2) -> bool {
    return dot(a, b) < 0;
}

hermite :: (points: [2] float, tangents: [2] float, t: float) -> float {
    n1 := 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2 := t * t * t - 2.0 * t * t + t;
    n3 := -2.0 * t * t * t + 3.0 * t * t;
    n4 := t * t * t - t * t;

    return n1 * points[0] + n2 * tangents[0] + n3 * points[1] + n4 * tangents[1];
}

hermite :: (points: [2] Vector2, tangents: [2] Vector2, t: float) -> Vector2 {
    n1 := 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2 := t * t * t - 2.0 * t * t + t;
    n3 := -2.0 * t * t * t + 3.0 * t * t;
    n4 := t * t * t - t * t;

    return n1 * points[0] + n2 * tangents[0] + n3 * points[1] + n4 * tangents[1];
}

hermite :: (points: [2] Vector3, tangents: [2] Vector3, t: float) -> Vector3 {
    n1 := 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2 := t * t * t - 2.0 * t * t + t;
    n3 := -2.0 * t * t * t + 3.0 * t * t;
    n4 := t * t * t - t * t;

    return n1 * points[0] + n2 * tangents[0] + n3 * points[1] + n4 * tangents[1];
}

hermite :: (points: [3] Vector3, tangents: [3] Vector3, t: float) -> Vector3 {
    if t < 0.5 {
        return hermite(.[points[0], points[1]], .[tangents[0], tangents[1]], t * 2);
    } else {
        return hermite(.[points[1], points[2]], .[tangents[1], tangents[2]], t * 2 - 1);
    }
}

hermite_velocity :: inline (positions: [2] Vector3, velocities: [2] Vector3, t: float) -> Vector3 {
    n1 := 6.0 * t * t - 6.0 * t;
    n2 := 6.0 * t - 6.0 * t * t;
    n3 := 3.0 * t * t;
    n4 := t;

    return positions[0] * n1 + positions[1] * n2 + (velocities[0] + velocities[1]) * n3 + (-4.0 * velocities[0] - 2 * velocities[1]) * n4 + velocities[0];

    // return n1 * positions[0] + n2 * velocities[0] + n3 * positions[1] + n4 * velocities[1];
}

// t brings you between points[0] and points[1] I think
hermite_points :: (points: [3] Vector3, t: float) -> Vector3 {
    tangents: [2] Vector3;
    tangents[0] = points[1] - points[0];
    tangents[1] = points[2] - points[1];

    hermite_points: [2] Vector3;
    hermite_points[0] = points[0];
    hermite_points[1] = points[1];
    return hermite(hermite_points, tangents, t);
}

hermite_points :: (points: [3] float, t: float) -> float {
    tangents: [2] float;
    tangents[0] = points[1] - points[0];
    tangents[1] = points[2] - points[1];

    hermite_points: [2] float;
    hermite_points[0] = points[0];
    hermite_points[1] = points[1];
    return hermite(hermite_points, tangents, t);
}

hermite_b_spline :: (points: [3] Vector3, t: float) -> Vector3 {
    center_points := Vector3.[
        (points[0] + points[1]) * 0.5,
        (points[1] + points[2]) * 0.5,
    ];
    // im not sure if this is supposed to be 0.5 or 1.0
    // 1.0 seems to produce the best results
    center_tangents := Vector3.[
        (points[1] - points[0]) * 1.0,
        (points[2] - points[1]) * 1.0,
    ];

    return hermite(center_points, center_tangents, t);
}

hermite_points :: (points: [4] Vector3, t: float) -> Vector3 {
    if t < 0.5 {
        return hermite_points(.[points[0], points[1], points[2]], t * 2);
    } else {
        return hermite_points(.[points[1], points[2], points[3]], t * 2 - 1);
    }
}

round :: (v: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = round(v.x);
    r.y = round(v.y);
    return r;
}

round :: (v: Vector3) -> Vector3 {
    r: Vector3 = ---;
    r.x = round(v.x);
    r.y = round(v.y);
    r.z = round(v.z);
    return r;
}

floor :: (v: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = floor(v.x);
    r.y = floor(v.y);
    return r;
}

ceil :: (v: Vector3) -> Vector3 {
    r: Vector3 = ---;
    r.x = ceil(v.x);
    r.y = ceil(v.y);
    r.z = ceil(v.z);
    return r;
}

ceil :: (v: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = ceil(v.x);
    r.y = ceil(v.y);
    return r;
}

normalize :: (v: Vector2) -> Vector2 {
    len2 := v.x * v.x + v.y * v.y;
    if len2 == 0 {
        return Vector2.{0, 0};
    }
    
    len := sqrt(len2);

    r: Vector2 = ---;
    r.x = v.x / len;
    r.y = v.y / len;

    return r;
}

dot :: (v: Vector2) -> float {
    return v.x * v.x + v.y * v.y;
}

operator += :: (a: *Vector2, b: Vector2) {
    a.x += b.x;
    a.y += b.y;
}

operator /= :: (a: *Vector2, b: Vector2) {
    a.x /= b.x;
    a.y /= b.y;
}

// operator - :: (a: Vector2) -> Vector2 {
//     r: Vector2 = ---;
//     r.x = -a.x;
//     r.y = -a.y;
//     return r;
// }

operator -= :: (a: *Vector2, b: Vector2) {
    a.x -= b.x;
    a.y -= b.y;
}

operator + :: (a: Vector2, b: float) -> Vector2 #symmetric {
    r: Vector2 = ---;
    r.x = a.x + b;
    r.y = a.y + b;
    return r;
}

operator / :: (a: Vector2, b: int) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x / b;
    r.y = a.y / b;
    return r;
}

operator * :: (a: Vector2, b: int) -> Vector2 #symmetric {
    r: Vector2 = ---;
    r.x = a.x * b;
    r.y = a.y * b;
    return r;
}

operator + :: (a: Vector3, b: float) -> Vector3 #symmetric {
    r: Vector3 = ---;
    r.x = a.x + b;
    r.y = a.y + b;
    r.z = a.z + b;
    return r;
}

operator - :: (a: Vector2, b: float) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x - b;
    r.y = a.y - b;
    return r;
}

operator - :: (a: Vector3, b: float) -> Vector3 {
    r: Vector3 = ---;
    r.x = a.x - b;
    r.y = a.y - b;
    r.z = a.z - b;
    return r;
}

operator - :: (a: float, b: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = a - b.x;
    r.y = a - b.y;
    return r;
}

operator - :: (a: float, b: Vector3) -> Vector3 {
    r: Vector3 = ---;
    r.x = a - b.x;
    r.y = a - b.y;
    r.z = a - b.z;
    return r;
}

// vector 64 stuff
vector3_64 :: (v: Vector3) -> Vector3_64 {
    r: Vector3_64 = ---;
    r.x = v.x;
    r.y = v.y;
    r.z = v.z;
    return r;
}

vector3 :: (v: Vector3_64) -> Vector3 {
    r: Vector3 = ---;
    r.x = cast(float) v.x;
    r.y = cast(float) v.y;
    r.z = cast(float) v.z;
    return r;
}

normalize :: (v: *Vector3_64, epsilon := 0.0, fallback := Vector3_64.{}) -> float64 {
    sq := length(v);
    if sq <= epsilon {
        v.* = fallback;
        return sq;
    }

    factor := 1 / sq;
    v.x *= factor;
    v.y *= factor;
    v.z *= factor;

    return sq;
} @NoProfile

normalize :: (v: Vector3_64, epsilon := 0.0, fallback := Vector3_64.{}) -> Vector3_64 {
    w := v;
    normalize(*w, epsilon, fallback);
    return w;
} @NoProfile

cross :: (a: Vector2_64, b: Vector2_64) -> float64 {
    // p205
    return a.y * b.x - a.x * b.y;
}

cross :: (a: Vector3_64, b: Vector3_64) -> Vector3_64 {
    n: Vector3_64 = ---;

    n.x = a.y * b.z - a.z * b.y;
    n.y = a.z * b.x - a.x * b.z;
    n.z = a.x * b.y - a.y * b.x;

    return n;
}

dot :: (a: Vector2_64, b: Vector2_64) -> float64 {
    return a.x * b.x + a.y * b.y;
}

dot :: (a: Vector3_64, b: Vector3_64) -> float64 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

length :: (a: Vector2_64) -> float64 {
    return sqrt(a.x * a.x + a.y * a.y);
}

length :: (a: Vector3_64) -> float64 {
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
}

round :: (v: Vector2_64) -> Vector2_64 {
    r: Vector2_64 = ---;
    r.x = round(v.x);
    r.y = round(v.y);
    return r;
}

round :: (v: Vector3_64) -> Vector3_64 {
    r: Vector3_64 = ---;
    r.x = round(v.x);
    r.y = round(v.y);
    r.z = round(v.z);
    return r;
}

floor :: (v: Vector2_64) -> Vector2_64 {
    r: Vector2_64 = ---;
    r.x = floor(v.x);
    r.y = floor(v.y);
    return r;
}

floor :: (v: Vector3_64) -> Vector3_64 {
    r: Vector3_64 = ---;
    r.x = floor(v.x);
    r.y = floor(v.y);
    r.z = floor(v.z);
    return r;
}

ceil :: (v: Vector2_64) -> Vector2_64 {
    r: Vector2_64 = ---;
    r.x = ceil(v.x);
    r.y = ceil(v.y);
    return r;
}

ceil :: (v: Vector3_64) -> Vector3_64 {
    r: Vector3_64 = ---;
    r.x = ceil(v.x);
    r.y = ceil(v.y);
    r.z = ceil(v.z);
    return r;
}

operator + :: (a: Vector2_64, b: Vector2_64) -> Vector2_64 {
    return .{a.x + b.x, a.y + b.y};
}

operator + :: (a: Vector3_64, b: Vector3_64) -> Vector3_64 {
    return .{a.x + b.x, a.y + b.y, a.z + b.z};
}

operator += :: (a: *Vector2_64, b: Vector2_64) {
    a.x += b.x;
    a.y += b.y;
}

operator += :: (a: *Vector3_64, b: Vector3_64) {
    a.x += b.x;
    a.y += b.y;
    a.z += b.z;
}

operator + :: (a: Vector2_64, b: float64) -> Vector2_64 #symmetric {
    return .{a.x + b, a.y + b};
}

operator + :: (a: Vector3_64, b: float64) -> Vector3_64 #symmetric {
    return .{a.x + b, a.y + b, a.z + b};
}

operator += :: (a: *Vector2_64, b: float64) {
    a.x += b;
    a.y += b;
}

operator += :: (a: *Vector3_64, b: float64) {
    a.x += b;
    a.y += b;
    a.z += b;
}

operator - :: (a: Vector2_64, b: Vector2_64) -> Vector2_64 {
    return .{a.x - b.x, a.y - b.y};
}

operator - :: (a: Vector3_64, b: Vector3_64) -> Vector3_64 {
    return .{a.x - b.x, a.y - b.y, a.z - b.z};
}

operator -= :: (a: *Vector2_64, b: Vector2_64) {
    a.x -= b.x;
    a.y -= b.y;
}

operator -= :: (a: *Vector3_64, b: Vector3_64) {
    a.x -= b.x;
    a.y -= b.y;
    a.z -= b.z;
}

operator - :: (a: Vector2_64, b: float64) -> Vector2_64 {
    return .{a.x - b, a.y - b};
}

operator - :: (a: Vector3_64, b: float64) -> Vector3_64 {
    return .{a.x - b, a.y - b, a.z - b};
}

operator -= :: (a: *Vector2_64, b: float64) {
    a.x -= b;
    a.y -= b;
}

operator -= :: (a: *Vector3_64, b: float64) {
    a.x -= b;
    a.y -= b;
    a.z -= b;
}

operator * :: (a: Vector2_64, b: Vector2_64) -> Vector2_64 {
    return .{a.x * b.x, a.y * b.y};
}

operator * :: (a: Vector3_64, b: Vector3_64) -> Vector3_64 {
    return .{a.x * b.x, a.y * b.y, a.z * b.z};
}

operator *= :: (a: *Vector2_64, b: Vector2_64) {
    a.x *= b.x;
    a.y *= b.y;
}

operator *= :: (a: *Vector3_64, b: Vector3_64) {
    a.x *= b.x;
    a.y *= b.y;
    a.z *= b.z;
}

operator * :: (a: Vector2_64, b: float64) -> Vector2_64 #symmetric {
    return .{a.x * b, a.y * b};
}

operator * :: (a: Vector3_64, b: float64) -> Vector3_64 #symmetric {
    return .{a.x * b, a.y * b, a.z * b};
}

operator *= :: (a: *Vector2_64, b: float64) {
    a.x *= b;
    a.y *= b;
}

operator *= :: (a: *Vector3_64, b: float64) {
    a.x *= b;
    a.y *= b;
    a.z *= b;
}

operator / :: (a: Vector2_64, b: Vector2_64) -> Vector2_64 {
    return .{a.x / b.x, a.y / b.y};
}

operator / :: (a: Vector3_64, b: Vector3_64) -> Vector3_64 {
    return .{a.x / b.x, a.y / b.y, a.z / b.z};
}

operator /= :: (a: *Vector2_64, b: Vector2_64) {
    a.x /= b.x;
    a.y /= b.y;
}

operator /= :: (a: *Vector3_64, b: Vector3_64) {
    a.x /= b.x;
    a.y /= b.y;
    a.z /= b.z;
}

operator / :: (a: Vector2_64, b: float64) -> Vector2_64 #symmetric {
    return .{a.x / b, a.y / b};
}

operator / :: (a: Vector3_64, b: float64) -> Vector3_64 #symmetric {
    return .{a.x / b, a.y / b, a.z / b};
}

operator /= :: (a: *Vector2_64, b: float64) {
    a.x /= b;
    a.y /= b;
}

operator /= :: (a: *Vector3_64, b: float64) {
    a.x /= b;
    a.y /= b;
    a.z /= b;
}

// float stuff
round :: (value: float) -> float {
    return floor(value + 0.5);
}

round :: (value: float64) -> float64 {
    return floor(value + 0.5);
}

roundi :: (value: float) -> int {
    return cast(int) floor(value + 0.5);
}

roundi :: (value: float64) -> s64 {
    return cast(s64) floor(value + 0.5);
}

inverse_quick_sin :: (v: float) -> float {
    return 0.5 * (1.0 - sqrt(1.0 - abs(v))) * sign(v);
}

safe_asin :: (x: float) -> float {
    return asin(clamp(x, -1.0, 1.0));
}

safe_asin :: (x: float64) -> float64 {
    return asin(clamp(x, -1.0, 1.0));
}

safe_acos :: (x: float) -> float {
    return acos(clamp(x, -1.0, 1.0));
}

safe_acos:: (x: float64) -> float64 {
    return acos(clamp(x, -1.0, 1.0));
}

pow :: (v: float, i: int) -> float {
    value := 1.0;
    for i: 0..i - 1 {
        value *= v;
    }

    return value;
}

quick_sin :: (t: float) -> float {
    // TODO is this really faster? I haven't tested it
    // -1 = 0
    // -0.5 = -1
    // 0 = 0
    // 0.5 = 1
    // 1 = 0
    return 4.0 * (abs(t) - t * t) * sign(t);
}

hermite_ease_in_out :: (t: float) -> float {
    n1: float = 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2: float = t * t * t - 2.0 * t * t + t;
    n3: float = -2.0 * t * t * t + 3.0 * t * t;
    n4: float = t * t * t - t * t;

    return n1 + n2 + n3 + n4;
}

bezier_ease_in_out :: (t: float) -> float {
    u := 1.0 - t;
    w3 := 3.0 * u * t * t;
    w4 := t * t * t;
    return w3 + w4;
}

quadratic_ease_out :: (t: float) -> float {
    return -t * (t - 2.0);
}

quadratic_ease_in :: (t: float) -> float {
    return t * t;
}

quadratic_ease_in_out :: (t: float) -> float {
    if t == 0 || t == 1 {
        return t;
    }

    if t < 0.5 {
        return 0.5 * pow(2.0, (20.0 * t) - 10.0);
    } else {
        return -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
    }
}

ease_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 2 * t * t;
    } else {
        p := -2 * t + 2;
        return 1 - p * p / 2;
    }
}

undo_ease_in_out :: (v: float) -> float {
    if v < 0.5 {
        // v = 2 * t * t
        // v / 2 = t * t
        // sqrt(v / 2) = t
        return sqrt(v / 2);
    } else {
        // v = 1 - (-2 * t + 2)^2 / 2
        // v - 1 = -(-2 * t + 2)^2 / 2
        // 1 - v = (-2 * t + 2)^2 / 2
        // 2 - 2 * v = (-2 * t + 2)^2
        // sqrt(2 - 2 * v) = -2 * t + 2
        // sqrt(2 - 2 * v) - 2 = -2 * t
        // (sqrt(2 - 2 * v) - 2) / -2 = t
        return sqrt(2 - 2 * v) / -2 + 1;
    }
}

ease_out_elastic :: (t: float, bounciness_mul: float = 10.0, bounce_mul: float = 1.0) -> float {
    c4 := 2.0 * PI / 3.0;

    if t == 0 {
        return 0.0;
    } else {
        if t == 1 {
            return 1.0;
        } else {
            return pow(2.0, -bounciness_mul * t) * ((sin((t * 10 - 0.75) * c4) + 1) * bounce_mul - 1) + 1;
        }
    }
}

ease_out_exp :: (t: float) -> float {
    return (1.0 - exp(-t * 2)) / 0.86466472;
}

smoothstep :: (edge0: float, edge1: float, x: float) -> float {
    t := clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

fmod :: fmod_cycling;

sign :: (value: int) -> int {
    return cast(int) (0 < value) - cast(int) (value < 0);
    // if value < 0 {
    //     return -1;
    // } else if value > 0 {
    //     return 1;
    // }

    // return 0;
}

dot :: (a: float, b: float) -> float {
    return a * b;
}

sign :: (value: float) -> float {
    return cast(float) (cast(int) (0.0 < value) - cast(int) (value < 0.0));
    // if value < 0 {
    //     return -1;
    // } else if value > 0 {
    //     return 1;
    // }

    // return 0;
}

sign :: (value: float64) -> float64 {
    return cast(float64) (cast(int) (0.0 < value) - cast(int) (value < 0.0));
    // if value < 0 {
    //     return -1;
    // } else if value > 0 {
    //     return 1;
    // }

    // return 0;
}

mod_radians :: (radians: float) -> float {
    // from -PI to PI
    percent := radians / PI / 2.0 + 0.5;
    // this should move something like -1.5PI to 0.5PI
    percent -= floor(percent);
    return percent * PI * 2 - PI;
}

radians_between :: (start: float, end: float) -> float {
    // TODO this is bad and probably slow I need to change it later
    if end < start {
        if start - end > PI {
            return PI * 2 - (start - end);
        } else {
            return -(start - end);
        }
    } else {
        if end - start > PI {
            return -(PI * 2 - (end - start));
        } else {
            return end - start;
        }
    }
}

#if INT_MATH {
    AABB2i :: struct {
        lower: Vector2i;
        upper: Vector2i;
    }

    AABB3i :: struct {
        lower: Vector3i;
        upper: Vector3i;
    }

    Line2i :: struct {
        p1: Vector2i;
        p2: Vector2i;
    }

    Line3i :: struct {
        p1: Vector3i;
        p2: Vector3i;
    }

    Vector2i :: struct {
        x: int;
        y: int;
    }

    Vector3i :: struct {
        x: int;
        y: int;
        z: int;
    }
    
    operator + :: (aabb: AABB2, v: Vector2i) -> AABB2 #symmetric {
        r: AABB2 = ---;
        r.lower = aabb.lower + v;
        r.upper = aabb.upper + v;
        return r;
    }

    operator + :: (aabb: AABB3, v: Vector3i) -> AABB3 #symmetric {
        r: AABB3 = ---;
        r.lower = aabb.lower + v;
        r.upper = aabb.upper + v;
        return r;
    }
    
    get_pixels :: (line: Line2i, inclusive: bool = true) -> [..] Vector2i {
        // modified bresenham’s to handle reverse lines and vertical lines
        x1 := line.p1.x;
        y1 := line.p1.y;
        x2 := line.p2.x;
        y2 := line.p2.y;

        dx := x2 - x1;
        dy := y2 - y1;

        pixels: [..] Vector2i;
        if abs(dx) >= abs(dy) {
            count := abs(dx) + ifx inclusive then 1 else 0;
            array_reserve(*pixels, count);

            x := x1;
            y := y1;

            if x2 > x1 {
                p := 2 * dy - dx;
                while x < x2 {
                    if p >= 0 {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        y = y + 1;
                        p = p + 2 * dy - 2 * dx;
                    } else {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        p = p + 2 * dy;
                    }

                    x = x + 1;
                }
            } else {
                p := -2 * dy + dx;
                while x > x2 {
                    if p >= 0 {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        y = y - 1;
                        p = p - 2 * dy + 2 * dx;
                    } else {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        p = p - 2 * dy;
                    }

                    x = x - 1;
                }
            }
        } else {
            count := abs(dy) + ifx inclusive then 1 else 0;
            array_reserve(*pixels, count);

            x := x1;
            y := y1;

            if y2 > y1 {
                p := 2 * dx - dy;
                while y < y2 {
                    if p >= 0 {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        x = x + 1;
                        p = p + 2 * dx - 2 * dy;
                    } else {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        p = p + 2 * dx;
                    }

                    y = y + 1;
                }
            } else {
                p := -2 * dx + dy;
                while y > y2 {
                    if p >= 0 {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        x = x - 1;
                        p = p - 2 * dx + 2 * dy;
                    } else {
                        point: Vector2i = ---;
                        point.x = x;
                        point.y = y;
                        array_add(*pixels, point);

                        p = p - 2 * dx;
                    }

                    y = y - 1;
                }
            }
        }

        if inclusive || (x1 == x2 && y1 == y2) {
            point: Vector2i = ---;
            point.x = x2;
            point.y = y2;
            array_add(*pixels, point);
        }

        return pixels;
    }

    roundi :: (aabb: AABB2) -> AABB2i {
        r: AABB2i = ---;
        r.lower = roundi(aabb.lower);
        r.upper = roundi(aabb.upper);
        return r;
    }
    
    roundi :: (v: Vector2) -> Vector2i {
        r: Vector2i = ---;
        r.x = cast(int) round(v.x);
        r.y = cast(int) round(v.y);
        return r;
    }

    roundi :: (v: Vector3) -> Vector3i {
        r: Vector3i = ---;
        r.x = cast(int) round(v.x);
        r.y = cast(int) round(v.y);
        r.z = cast(int) round(v.z);
        return r;
    }
    
    xy :: (x: int, y: int) -> Vector2i {
        r: Vector2i = ---;
        r.x = x;
        r.y = y;
        return r;
    }

    xyz :: (x: int, y: int, z: int) -> Vector3i {
        r: Vector3i = ---;
        r.x = x;
        r.y = y;
        r.z = z;
        return r;
    }

    operator == :: (a: Vector2i, b: Vector2i) -> bool {
        return a.x == b.x && a.y == b.y;
    }

    operator == :: (a: Vector3i, b: Vector3i) -> bool {
        return a.x == b.x && a.y == b.y && a.z == b.z;
    }

    operator + :: (a: Vector2i, b: Vector2i) -> Vector2i {
        r: Vector2i = ---;
        r.x = a.x + b.x;
        r.y = a.y + b.y;
        return r;
    }

    // these methods dont seem to work?
    operator + :: (a: *Vector2i, b: Vector2i) {
        a.x += b.x;
        a.y += b.y;
    }

    operator + :: (a: Vector3i, b: Vector3i) -> Vector3i {
        r: Vector3i = ---;
        r.x = a.x + b.x;
        r.y = a.y + b.y;
        r.z = a.z + b.z;
        return r;
    }

    operator + :: (a: *Vector3i, b: Vector3i) {
        a.x += b.x;
        a.y += b.y;
        a.z += b.z;
    }

    operator + :: (a: Vector2i, b: Vector2) -> Vector2 #symmetric {
        r: Vector2 = ---;
        r.x = a.x + b.x;
        r.y = a.y + b.y;
        return r;
    }

    operator + :: (a: Vector3i, b: Vector3) -> Vector3 #symmetric {
        r: Vector3 = ---;
        r.x = a.x + b.x;
        r.y = a.y + b.y;
        r.z = a.z + b.z;
        return r;
    }

    operator - :: (a: Vector2i, b: Vector2i) -> Vector2i {
        r: Vector2i = ---;
        r.x = a.x - b.x;
        r.y = a.y - b.y;
        return r;
    }

    operator - :: (a: *Vector2i, b: Vector2i) {
        a.x -= b.x;
        a.y -= b.y;
    }

    operator - :: (a: Vector3i, b: Vector3i) -> Vector3i {
        r: Vector3i = ---;
        r.x = a.x - b.x;
        r.y = a.y - b.y;
        r.z = a.z - b.z;
        return r;
    }

    operator - :: (a: *Vector3i, b: Vector3i) {
        a.x -= b.x;
        a.y -= b.y;
        a.z -= b.z;
    }

    operator - :: (a: Vector2i, b: Vector2) -> Vector2 {
        r: Vector2 = ---;
        r.x = a.x - b.x;
        r.y = a.y - b.y;
        return r;
    }

    operator - :: (a: *Vector2, b: Vector2i) {
        a.x -= b.x;
        a.y -= b.y;
    }

    operator - :: (a: Vector3i, b: Vector3) -> Vector3 {
        r: Vector3 = ---;
        r.x = a.x - b.x;
        r.y = a.y - b.y;
        r.z = a.z - b.z;
        return r;
    }

    operator - :: (a: *Vector3, b: Vector3i) {
        a.x -= b.x;
        a.y -= b.y;
        a.z -= b.z;
    }

    operator * :: (a: Vector2i, b: Vector2i) -> Vector2i {
        r: Vector2i = ---;
        r.x = a.x * b.x;
        r.y = a.y * b.y;
        return r;
    }

    operator * :: (a: *Vector2i, b: Vector2i) {
        a.x *= b.x;
        a.y *= b.y;
    }

    operator * :: (a: Vector3i, b: Vector3i) -> Vector3i {
        r: Vector3i = ---;
        r.x = a.x * b.x;
        r.y = a.y * b.y;
        r.z = a.z * b.z;
        return r;
    }

    operator * :: (a: *Vector3i, b: Vector3i) {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
    }

    operator * :: (a: Vector2i, b: Vector2) -> Vector2 #symmetric {
        r: Vector2 = ---;
        r.x = a.x * b.x;
        r.y = a.y * b.y;
        return r;
    }

    operator * :: (a: *Vector2, b: Vector2i) {
        a.x *= b.x;
        a.y *= b.y;
    }

    operator * :: (a: Vector3i, b: Vector3) -> Vector3 #symmetric {
        r: Vector3 = ---;
        r.x = a.x * b.x;
        r.y = a.y * b.y;
        r.z = a.z * b.z;
        return r;
    }

    operator * :: (a: *Vector3, b: Vector3i) {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
    }

    operator * :: (a: Vector2i, k: int) -> Vector2i #symmetric {
        r: Vector2i = ---;
        r.x = a.x * k;
        r.y = a.y * k;

        return r;
    }

    operator * :: (a: *Vector2i, k: int) {
        a.x *= k;
        a.y *= k;
    }

    operator * :: (a: Vector3i, k: int) -> Vector3i #symmetric {
        r: Vector3i = ---;
        r.x = a.x * k;
        r.y = a.y * k;
        r.z = a.z * k;

        return r;
    }

    operator * :: (a: Vector2i, k: float) -> Vector2 #symmetric {
        r: Vector2 = ---;
        r.x = a.x * k;
        r.y = a.y * k;

        return r;
    }

    operator * :: (a: Vector3i, k: float) -> Vector3 #symmetric {
        r: Vector3 = ---;
        r.x = a.x * k;
        r.y = a.y * k;
        r.z = a.z * k;

        return r;
    }

    operator / :: (a: Vector2i, k: int) -> Vector2i {
        r: Vector2i = ---;
        r.x = a.x / k;
        r.y = a.y / k;
        return r;
    }

    operator / :: (a: Vector3i, k: int) -> Vector3i {
        r: Vector3i = ---;
        r.x = a.x / k;
        r.y = a.y / k;
        r.z = a.z / k;
        return r;
    }

    operator / :: (a: Vector2i, k: float) -> Vector2 {
        r: Vector2 = ---;
        r.x = a.x / k;
        r.y = a.y / k;
        return r;
    }

    operator / :: (a: Vector3i, k: float) -> Vector3 {
        r: Vector3 = ---;
        r.x = a.x / k;
        r.y = a.y / k;
        r.z = a.z / k;
        return r;
    }

    operator / :: (k: int, a: Vector2i) -> Vector2i {
        r: Vector2i = ---;
        r.x = k / a.x;
        r.y = k / a.y;
        return r;
    }

    operator / :: (k: int, a: Vector3i) -> Vector3i {
        r: Vector3i = ---;
        r.x = k / a.x;
        r.y = k / a.y;
        r.z = k / a.z;
        return r;
    }

    operator / :: (k: float, a: Vector2i) -> Vector2 {
        r: Vector2 = ---;
        r.x = k / a.x;
        r.y = k / a.y;
        return r;
    }

    operator / :: (k: float, a: Vector3i) -> Vector3 {
        r: Vector3 = ---;
        r.x = k / a.x;
        r.y = k / a.y;
        r.z = k / a.z;
        return r;
    }
}

// physics stuff

get_timed_launch_angle_velocity :: (start: Vector3, end: Vector3, gravity: float, air_duration: float) -> float, float {
    // dy = v0 * t * sin(theta) - 0.5 * g * t^2
    // im gonna assume sin(theta) is pointing always up to find vertical velocity
    // dy = v0 * t - 0.5 * g * t^2
    // dy - v0 * t = -0.5 * g * t^2
    // v0 * t - dy = 0.5 * g * t^2
    // v0 * t = 0.5 * g * t^2 + dy
    // v0 = 0.5 * g * t + dy / t

    delta := end - start;
    x := length(Vector2.{delta.x, delta.z});
    y := delta.y;

    vertical_speed := 0.5 * gravity * air_duration + y / air_duration;
    horizontal_speed := x / air_duration;

    launch_angle := atan(vertical_speed / horizontal_speed);
    launch_speed := sqrt(horizontal_speed * horizontal_speed + vertical_speed * vertical_speed);

    return launch_angle, launch_speed;
}

get_minimum_launch_angle_velocity :: (start: Vector3, end: Vector3, gravity: float) -> float, float {
    // gravity is a positive number
    delta := end - start;
    x := length(Vector2.{delta.x, delta.z});
    y := delta.y;

    // https://en.wikipedia.org/wiki/Projectile_motion
    launch_angle := atan(y / x + sqrt((y * y) / (x * x) + 1));

    // v^2 / g = y + sqrt(y^2 + x^2);
    launch_speed := sqrt(gravity * (y + sqrt(x * x + y * y)));

    // velocity := normalize(Vector3.{delta.x, 0, delta.z}) * cos(launch_angle) + Vector3.{0, 1, 0} * sin(launch_angle);
    // velocity *= launch_speed;

    return launch_angle, launch_speed;
}

#scope_file

#import "Basic";
#import "Math";

EPSILON :: 0.000001;
PI_2 :: PI * 2;

DEBUG :: !PRODUCTION;
INT_MATH :: false;

AnyPlane3 :: Type.[Plane3, Plane3_64];
AnyVector2 :: Type.[Vector2, Vector2_64];
AnyVector3 :: Type.[Vector3, Vector3_64];
AnyVector4 :: Type.[Vector4, Vector4_64];

validate_unit_vector :: inline (v: $T/AnyVector2) {
    if abs(length(v) - 1) > EPSILON {
        print("Invalid unit vector: %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}

validate_unit_vector :: inline (v: $T/AnyVector3) {
    if abs(length(v) - 1) > EPSILON {
        print("Invalid unit vector: %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}

validate_ccw :: inline (v: [] $T/AnyVector2) {
    if !is_ccw(v) {
        print("Invalid polygon winding. %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}
