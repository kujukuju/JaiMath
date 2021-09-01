// page numbers come from "Real Time Collision Detection by Christer Ericson"

Sphere :: struct {
    c: Vector3;
    r: float;
}

AABB2 :: struct {
    lower: Vector2;
    upper: Vector2;
}

AABB3 :: struct {
    lower: Vector3;
    upper: Vector3;
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

Ray2 :: struct {
    p: Vector2;
    dir: Vector2;
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

// convex polygon stuff
intersects :: (polygon: [] Vector2, point: Vector2) -> bool {
    // p202
    #if DEBUG validate_ccw(polygon);

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
        ood := 1 / ray.dir.x;
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
        ood := 1 / ray.dir.y;
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

intersection :: (aabb: AABB3, ray: Ray3, t: *float) -> Vector3, bool {
    // p180
    #if DEBUG validate_unit_vector(ray.dir);

    << t = 0; // set to -FLT_MAX to get first hit on line
    tmax := FLOAT32_MAX; // set to max distance ray can travel (for segment)
    // For all three slabs
    if abs(ray.dir.x) < EPSILON {
        // Ray is parallel to slab. No hit if origin not within slab
        if ray.p.x < aabb.lower.x || ray.p.x > aabb.upper.x {
            return .{0, 0, 0}, false;
        }
    } else {
        // Compute intersection t value of ray with near and far plane of slab
        ood := 1 / ray.dir.x;
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
            return .{0, 0, 0}, false;
        }
    }
    if abs(ray.dir.y) < EPSILON {
        // Ray is parallel to slab. No hit if origin not within slab
        if ray.p.y < aabb.lower.y || ray.p.y > aabb.upper.y {
            return .{0, 0, 0}, false;
        }
    } else {
        // Compute intersection t value of ray with near and far plane of slab
        ood := 1 / ray.dir.y;
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
            return .{0, 0, 0}, false;
        }
    }
    if abs(ray.dir.z) < EPSILON {
        // Ray is parallel to slab. No hit if origin not within slab
        if ray.p.z < aabb.lower.z || ray.p.z > aabb.upper.z {
            return .{0, 0, 0}, false;
        }
    } else {
        // Compute intersection t value of ray with near and far plane of slab
        ood := 1 / ray.dir.z;
        t1 := (aabb.lower.z - ray.p.z) * ood;
        t2 := (aabb.upper.z - ray.p.z) * ood;
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
            return .{0, 0, 0}, false;
        }
    }
    // Ray intersects all 3 slabs. Return point (q) and intersection t value (tmin)
    return ray.p + ray.dir * << t, true;
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

// triangle stuff
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
    if cross(point - triangle.a, triangle.b - triangle.a) < 0 return false;
    // If P to the right of BC then outside triangle
    if cross(point - triangle.b, triangle.c - triangle.b) < 0 return false;
    // If P to the right of CA then outside triangle
    if cross(point - triangle.c, triangle.a - triangle.c) < 0 return false;
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
distance :: (ray: Ray2, point: Vector2) -> float {
    // real time collision, p127
    #if DEBUG validate_unit_vector(ray.dir);

    d := ray.dir.x * ray.dir.x + ray.dir.y * ray.dir.y;
    return ray.dir.x * point.x + ray.dir.y * point.y - d;
}

distance :: (ray: Ray3, point: Vector3) -> float {
    // real time collision, p127
    #if DEBUG validate_unit_vector(ray.dir);

    d := ray.dir.x * ray.dir.x + ray.dir.y * ray.dir.y + ray.dir.z * ray.dir.z;
    return ray.dir.x * point.x + ray.dir.y * point.y + ray.dir.z * point.z - d;
}

// line stuff
get_pixels :: (line: Line2, inclusive: bool = true) -> [..] [2] int {
    // modified bresenham’s to handle reverse lines and vertical lines
    x1: int = cast(int) round(line.p1.x);
    y1: int = cast(int) round(line.p1.y);
    x2: int = cast(int) round(line.p2.x);
    y2: int = cast(int) round(line.p2.y);

    dx := x2 - x1;
    dy := y2 - y1;

    pixels: [..] [2] int;
    if abs(dx) >= abs(dy) {
        count := abs(dx) + ifx inclusive then 1 else 0;
        array_reserve(*pixels, count);

        x := x1;
        y := y1;

        if x2 > x1 {
            p := 2 * dy - dx;
            while x < x2 {
                if p >= 0 {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    y = y + 1;
                    p = p + 2 * dy - 2 * dx;
                } else {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    p = p + 2 * dy;
                }

                x = x + 1;
            }
        } else {
            p := -2 * dy + dx;
            while x > x2 {
                if p >= 0 {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    y = y - 1;
                    p = p - 2 * dy + 2 * dx;
                } else {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
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
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    x = x + 1;
                    p = p + 2 * dx - 2 * dy;
                } else {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    p = p + 2 * dx;
                }

                y = y + 1;
            }
        } else {
            p := -2 * dx + dy;
            while y > y2 {
                if p >= 0 {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    x = x - 1;
                    p = p - 2 * dx + 2 * dy;
                } else {
                    point: [2] int;
                    point[0] = x;
                    point[1] = y;
                    array_add(*pixels, point);

                    p = p - 2 * dx;
                }

                y = y - 1;
            }
        }
    }

    if inclusive || (x1 == x2 && y1 == y2) {
        point: [2] int;
        point[0] = x2;
        point[1] = y2;
        array_add(*pixels, point);
    }

    return pixels;
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

// matrix stuff
make_rotation_matrix4 :: (axis: Vector3, radians: float) -> Matrix4 {
    return make_rotation_matrix4(make_rotation_quaternion(axis, radians));
}

// quat stuff
make_rotation_quaternion :: (axis: Vector3, radians: float) -> Quaternion {
    d := length(axis);
    if d == 0 return Quaternion.{0, 0, 0, 1};

    d = 1.0 / d;
    l_ang := ifx radians < 0 then PI_2 - (fmod(-radians, PI_2)) else fmod(radians, PI_2);
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
rotate :: (vector: Vector3, axis: Vector3, radians: float) -> Vector3 {
    direction := make_vector4(vector.x, vector.y, vector.z, 1);
    return (make_rotation_matrix4(axis, radians) * direction).xyz;
}

min :: (a: Vector2, b: Vector2) -> Vector2 {
    vector: Vector2 = ---;
    vector.x = min(a.x, b.x);
    vector.y = min(a.y, b.y);
    return vector;
}

min :: (a: Vector3, b: Vector3) -> Vector3 {
    vector: Vector3 = ---;
    vector.x = min(a.x, b.x);
    vector.y = min(a.y, b.y);
    vector.z = min(a.z, b.z);
    return vector;
}

max :: (a: Vector2, b: Vector2) -> Vector2 {
    vector: Vector2 = ---;
    vector.x = max(a.x, b.x);
    vector.y = max(a.y, b.y);
    return vector;
}

max :: (a: Vector3, b: Vector3) -> Vector3 {
    vector: Vector3 = ---;
    vector.x = max(a.x, b.x);
    vector.y = max(a.y, b.y);
    vector.z = max(a.z, b.z);
    return vector;
}

cross :: (a: Vector2, b: Vector2) -> float {
    // p205
    return a.y * b.x - a.x * b.y;
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

// float stuff
round :: (value: float) -> float {
    if value < 0.0 {
        return floor(value - 0.5);
    }

    return floor(value + 0.5);
}

round :: (value: float64) -> float64 {
    if value < 0.0 {
        return floor(value - 0.5);
    }

    return floor(value + 0.5);
}

sign :: (value: int) -> int {
    if value < 0 {
        return -1;
    } else if value > 0 {
        return 1;
    }

    return 0;
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

#scope_file
#import "Basic";
#import "Math";

EPSILON :: 0.000001;
PI_2 :: PI * 2;

DEBUG :: true;

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
    // TODO
}