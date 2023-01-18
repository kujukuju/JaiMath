// page numbers come from "Real Time Collision Detection by Christer Ericson"

Sphere :: struct {
    c: Vector3;
    r: float;
}

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

create_plane3 :: (p: Vector3, n: Vector3) -> Plane3 {
    result: Plane3 = ---;
    result.a = n.x;
    result.b = n.y;
    result.c = n.z;
    result.d = dot(n, p);

    return result;
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

Line2 :: struct {
    p1: Vector2;
    p2: Vector2;
}

Line3 :: struct {
    p1: Vector3;
    p2: Vector3;
}

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

    right :: (a: Vector2, b: Vector2, p: Vector2) -> bool {
        return (b.x - a.x) * (p.y - a.y) - (p.x - a.x) * (b.y - a.y) > 0;
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

interesct_ray_convex_polygon :: (ray: Ray2, polygon: [] Vector2) -> bool, first: float, last: float, last_normal: Vector2 {
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

// sphere stuff
// Determine whether plane p intersects sphere s
intersection :: (sphere: Sphere, ray: Ray3) -> Vector3, bool {
    t: float = 0;
    vector, value := intersection(sphere, ray, *t);
    return vector, value;
}

intersection :: (sphere: Sphere, ray: Ray3, t: *float) -> Vector3, bool {
    // p178
    #if DEBUG validate_unit_vector(ray.dir);

    m := ray.p - sphere.c;
    b := dot(m, ray.dir);
    c := dot(m, m) - sphere.r * sphere.r;
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
    
    m := ray.p - sphere.c;
    c := dot(m, m) - sphere.r * sphere.r;
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
    dist := dot(sphere.c, plane.n) - plane.d;
    // If sphere center within +/-radius from plane, plane intersects sphere
    return abs(dist) <= sphere.r;
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

intersection :: (plane: Plane3, ray: Ray3) -> Vector3, bool {
    // p176
    #if DEBUG validate_unit_vector(plane.n);
    #if DEBUG validate_unit_vector(ray.dir);

    // does not handle division by 0
    // compute the t value for the directed line ab intersecting the plane
    t := (plane.d - dot(plane.n, ray.p)) / dot(plane.n, ray.dir);
    if t >= 0 {
        return ray.p + t * ray.dir, true;
    }
    
    return .{0, 0, 0}, false;
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

// Determine whether sphere s is fully behind (inside negative halfspace of) plane p
inside :: (plane: Plane3, sphere: Sphere) -> bool {
    // p161
    #if DEBUG validate_unit_vector(plane.n);

    dist := dot(sphere.c, plane.n) - plane.d;
    return dist < -sphere.r;
}

nearest_point :: (plane: Plane3, point: Vector3) -> Vector3 {
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

    << t = 0; // set to -FLT_MAX to get first hit on line
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

    if d1.x > 0 || d1.y > 0 || d1.z > 0 {
        return false;
    }

    if d2.x > 0 || d2.y > 0 || d2.z > 0 {
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

contains :: (aabb: AABB2, point: Vector2) -> bool {
    return point.x >= aabb.lower.x && point.y >= aabb.lower.y && point.x < aabb.upper.x && point.y < aabb.upper.y;
}

round :: (aabb: AABB2) -> AABB2 {
    r: AABB2 = ---;
    r.lower = round(aabb.lower);
    r.upper = round(aabb.upper);
    return r;
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

area_signed :: (triangle: Triangle2) -> float {
    // p152
    return (triangle.a.x - triangle.c.x) * (triangle.b.y - triangle.c.y) - (triangle.a.y - triangle.c.y) * (triangle.b.x - triangle.c.x);
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

nearest_point :: (ray: Ray3, point: Vector3) -> Vector3 {
    #if DEBUG validate_unit_vector(ray.dir);

    // p128
    t := dot(point - ray.p, ray.dir) / dot(ray.dir, ray.dir);

    return ray.p + t * ray.dir;
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
nearest_point :: (ray: Ray2, point: Vector2) -> Vector2 {
    return dot(point - ray.p, ray.dir) / dot(ray.dir, ray.dir) * ray.dir + ray.p;
}

// line stuff
nearest_point :: (line: Line3, ray: Ray3) -> Vector3 {
    #if DEBUG validate_unit_vector(ray.dir);

    line_ray := Ray3.{line.p1, normalize(line.p2 - line.p1)};

    line_ray_nearest := nearest_point(line_ray, ray);

    return nearest_point(line, line_ray_nearest);
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

    a1 := area_signed(abd); // Compute winding of abd (+ or -)
    a2 := area_signed(abc); // To intersect, must have sign opposite of a1

    // If c and d are on different sides of ab, areas have different signs
    if a1 * a2 < 0 {
        // Compute signs for a and b with respect to segment cd
        cda: Triangle2 = ---;
        cda.a = line2.p1;
        cda.b = line2.p2;
        cda.c = line1.p1;

        a3 := area_signed(cda); // Compute winding of cda (+ or -)
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

nearest_point :: (line: Line2, point: Vector2) -> Vector2 {
    t: float = 0;
    return nearest_point(line, point, *t);
}

nearest_point :: (line: Line3, point: Vector3) -> Vector3 {
    t: float = 0;
    return nearest_point(line, point, *t);
}

nearest_point :: (line: Line2, point: Vector2, t: *float) -> Vector2 {
    // p128
    ab := line.p2 - line.p1;
    << t = dot(point - line.p1, ab) / dot(ab, ab);
    if << t < 0.0 {
        << t = 0.0;
    }
    if << t > 1.0 {
        << t = 1.0;
    }

    return line.p1 + << t * ab;
}

nearest_point :: (line: Line3, point: Vector3, t: *float) -> Vector3 {
    // p128
    ab := line.p2 - line.p1;
    << t = dot(point - line.p1, ab) / dot(ab, ab);
    if << t < 0.0 {
        << t = 0.0;
    }
    if << t > 1.0 {
        << t = 1.0;
    }

    return line.p1 + << t * ab;
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
reverse :: (v: [] Vector2) -> [..] Vector2 {
    new: [..] Vector2;
    for i: 0..v.count - 1 {
        index := v.count - i - 1;
        array_add(*new, v[index]);
    }

    return new;
}

reverse :: (v: *[] Vector2) {
    for i: 0..v.count / 2 - 1 {
        p1, p2 := swap(v.data[i], v.data[v.count - i - 1]);
        v.data[i] = p1;
        v.data[v.count - i - 1] = p2;
    }
}

// matrix stuff
make_rotation_matrix4 :: (axis: Vector3, radians: float) -> Matrix4 {
    return make_rotation_matrix4(axis, radians);
}

// quat stuff
make_rotation_quaternion :: (axis: Vector3, radians: float) -> Quaternion {
    d := length(axis);
    if d == 0 return Quaternion.{0, 0, 0, 1};

    d = 1.0 / d;
    l_ang := ifx radians < 0 then PI_2 - (fmod_cycling(-radians, PI_2)) else fmod_cycling(radians, PI_2);
    l_sin := sin(l_ang / 2);
    l_cos := cos(l_ang / 2);
    return normalize(make_quaternion(d * axis.x * l_sin, d * axis.y * l_sin, d * axis.z * l_sin, l_cos));
}

normalize :: (using quat: Quaternion) -> Quaternion {
    sq := sqrt(x * x + y * y + z * z + w * w);
    if sq == 0 {
        return quat;
    }

    factor := 1.0 / sq;
    return make_quaternion(x * factor, y * factor, z * factor, w * factor);
}

// vector stuff
project :: (dest: Vector3, src: Vector3) -> Vector3 {
    return (dot(src, dest) / dot(dest, dest)) * dest;
}

project :: (dest: Vector2, src: Vector2) -> Vector2 {
    return (dot(src, dest) / dot(dest, dest)) * dest;
}

inverse_project :: (dest: Vector2, src: Vector2) -> Vector2 {
    // projects src onto dest but makes a right angle with src so that the final result is much larger
    theta := acos(dot(src, dest) / (length(src) * length(dest)));

    projection_length := length(src) / sin(PI / 2 - theta);
    return normalize(dest) * projection_length;
}

rotate :: (vector: Vector3, axis: Vector3, radians: float) -> Vector3 {
    direction := make_vector4(vector.x, vector.y, vector.z, 1);
    return (make_rotation_matrix4(axis, radians) * direction).xyz;
}

perp :: (vector: Vector2) -> Vector2 {
    return xy(-vector.y, vector.x);
}

distance_squared :: (a: Vector2, b: Vector2) -> float {
    return length_squared(a - b);
}

length_squared :: (a: Vector2) -> float {
    return a.x * a.x + a.y * a.y;
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

hermite :: (points: [2] Vector2, tangents: [2] Vector2, t: float) -> Vector2 {
    n1: float = 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2: float = t * t * t - 2.0 * t * t + t;
    n3: float = -2.0 * t * t * t + 3.0 * t * t;
    n4: float = t * t * t - t * t;

    vector: Vector2 = ---;
    vector.x = n1 * points[0].x + n2 * tangents[0].x + n3 * points[1].x + n4 * tangents[1].x;
    vector.y = n1 * points[0].y + n2 * tangents[0].y + n3 * points[1].y + n4 * tangents[1].y;

    return vector;
}

hermite :: (points: [2] Vector3, tangents: [2] Vector3, t: float) -> Vector3 {
    n1: float = 2.0 * t * t * t - 3.0 * t * t + 1.0;
    n2: float = t * t * t - 2.0 * t * t + t;
    n3: float = -2.0 * t * t * t + 3.0 * t * t;
    n4: float = t * t * t - t * t;

    vector: Vector3 = ---;
    vector.x = n1 * points[0].x + n2 * tangents[0].x + n3 * points[1].x + n4 * tangents[1].x;
    vector.y = n1 * points[0].y + n2 * tangents[0].y + n3 * points[1].y + n4 * tangents[1].y;
    vector.z = n1 * points[0].z + n2 * tangents[0].z + n3 * points[1].z + n4 * tangents[1].z;

    return vector;
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

operator - :: (a: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = -a.x;
    r.y = -a.y;
    return r;
}

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

sign :: (value: int) -> int {
    if value < 0 {
        return -1;
    } else if value > 0 {
        return 1;
    }

    return 0;
}

dot :: (a: float, b: float) -> float {
    return a * b;
}

sign :: (value: float) -> float {
    if value < 0 {
        return -1;
    } else if value > 0 {
        return 1;
    }

    return 0;
}

sign :: (value: float64) -> float64 {
    if value < 0 {
        return -1;
    } else if value > 0 {
        return 1;
    }

    return 0;
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

#scope_file
#import "Basic";
#import "Math";

EPSILON :: 0.000001;
PI_2 :: PI * 2;

DEBUG :: true;
INT_MATH :: false;

validate_unit_vector :: inline (v: Vector2) {
    if abs(length(v) - 1) > EPSILON {
        print("Invalid unit vector: %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}

validate_unit_vector :: inline (v: Vector3) {
    if abs(length(v) - 1) > EPSILON {
        print("Invalid unit vector: %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}

validate_ccw :: inline (v: [] Vector2) {
    if !is_ccw(v) {
        print("Invalid polygon winding. %\nExiting.\n", v);
        print_stack_trace(context.stack_trace);
        exit(1);
    }
}