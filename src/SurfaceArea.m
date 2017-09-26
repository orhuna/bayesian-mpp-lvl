function area = SurfaceArea(surface)

if size(surface.faces,1) == 0
    area = 0 ;
else

a = surface.vertices(surface.faces(:, 2), :) - surface.vertices(surface.faces(:, 1), :);

b = surface.vertices(surface.faces(:, 3), :) - surface.vertices(surface.faces(:, 1), :);

c = cross(a, b, 2);

area = 1/2 * sum(sqrt(sum(c.^2, 2)));

end
end