f = uifigure('Color', 'w');
t = tiledlayout(f, 1, 1);
ax = nexttile(t);

% Plot dummy data
x = 1:10;
y = rand(1, 10);
p = plot(ax, x, y);

% Ensure only axes capture the click
p.HitTest = "off";
ax.PickableParts = "all";
ax.HitTest = "on";

% Assign ButtonDownFcn
ax.ButtonDownFcn = @(src, event) disp('Axes clicked!');