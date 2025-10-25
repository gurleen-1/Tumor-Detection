%% Brain MRI Tumour Flagger: Original | Detecting Tumour | Percentage of Tumour
% Base MATLAB only. Research demo — not for diagnosis.

clc; clear; close all;

%% ---------------------- USER SETTINGS -----------------------------------
imgPath      = "Y100.jpeg";   % MRI image filename (PNG/JPG/TIF/DICOM)
sliceType    = "T1c";         % 'T1c' | 'T2' | 'FLAIR'
zThrBase     = 2.0;           % Base z-threshold for hotspots
sigma        = 1.2;           % Gaussian smoothing level
centerMargin = 0.00;          % Use full image for mask
alphaMax     = 0.65;          % Overlay opacity (right panel)
gamma        = 0.7;           % Overlay gamma (right panel)

%% ---------------------- LOAD & PREP -------------------------------------
I0 = load_image_safe(imgPath);
I  = to_grayscale_double(I0);
I  = normalize01(I);

%% ---------------------- DENOISE -----------------------------------------
gk = gaussian_kernel(sigma);
If = conv2(I, gk, 'same');

%% ---------------------- SIMPLE BRAIN MASK --------------------------------
[H,W] = size(If);
pad   = round(min(H,W)*centerMargin);
mask  = false(H,W);
mask(1+pad:end-pad, 1+pad:end-pad) = true;

%% ---------------------- Z-SCORE MAP -------------------------------------
mu   = mean(If(mask));
sd   = std(If(mask));
zmap = zeros(H,W);
zmap(mask) = (If(mask) - mu) / (sd + eps);

switch lower(sliceType)
    case "t1c",  zThr = zThrBase;
    case "t2",   zThr = zThrBase + 0.2;
    case "flair",zThr = zThrBase + 0.1;
    otherwise,   zThr = zThrBase;
end

candBW = (zmap > zThr) & mask;

%% ---------------------- REGION FROM STRONGEST HOTSPOT -------------------
[yList, xList] = find(candBW);
tumorMask = false(H,W);
centroid = []; eqRadius = 0; detected = false; hullX = []; hullY = [];

if ~isempty(yList)
    [~, idxMax] = max(zmap(candBW));
    ySeed = yList(idxMax); xSeed = xList(idxMax);
    tumorMask = region_from_seed(candBW, ySeed, xSeed) & mask;

    [ry, rx] = find(tumorMask);
    if ~isempty(ry)
        detected = true;
        areaPx   = numel(ry);
        centroid = [mean(ry), mean(rx)];          % [y, x]
        eqRadius = max(8, sqrt(areaPx/pi));       % min radius for visibility
        % convex hull for filled patch (right panel)
        try
            K = convhull(rx, ry); hullX = rx(K); hullY = ry(K);
        catch
            hullX = []; hullY = [];
        end
    end
end

%% ---------------------- % AFFECTED / SAFE -------------------------------
brainArea       = nnz(mask);
tumorArea       = nnz(tumorMask);
affectedPercent = 100 * (tumorArea / max(1, brainArea));
safePercent     = max(0, 100 - affectedPercent);

%% ---------------------- RIGHT-PANEL COMPOSITE (negative + overlay) ------
Ineg    = 1 - I;                        % negative grayscale
InegRGB = repmat(Ineg, [1 1 3]);        % RGB for blending

% Build colorful overlay from z-scores above threshold
zAbove  = max(0, zmap - zThr);
zNorm   = zAbove ./ (max(zAbove(:))+eps);
zNorm   = zNorm .^ gamma;

% Map zNorm -> RGB
cmap = parula(256);
idx  = 1 + floor(255 * normalize01(zNorm));  % 1..256 indices
overlayRGB = zeros(H,W,3);
for ch = 1:3
    overlayRGB(:,:,ch) = reshape(cmap(idx, ch), H, W);
end

% Transparency: stronger where z is higher, only inside mask
alpha = alphaMax * zNorm .* double(mask);

% Blend: composite = (1-alpha)*base + alpha*overlay
compRGB = (1 - alpha).*InegRGB + alpha.*overlayRGB;

%% ---------------------- CENTER-PANEL HEATMAP (auto-cropped) -------------
% vivid PET-like heatmap of z-scores
zClip  = max(-1, min(3, zmap));                   % clip for stability/contrast
zShow  = (zClip - (-1)) / (3 - (-1) + eps);       % normalize to [0,1]
mapHeat = jet(256);                                % vivid colors
idxH   = 1 + floor(255 * zShow);
heatRGB = zeros(H,W,3);
for ch = 1:3
    heatRGB(:,:,ch) = reshape(mapHeat(idxH, ch), H, W);
end

% Auto-crop out the low-z frame (no border), then resize back to [H W]
zMask = zShow > 0.08;                              % content mask
if any(zMask(:))
    [yy, xx] = find(zMask);
    padCrop = 4;
    y1 = max(1, min(yy)-padCrop); y2 = min(H, max(yy)+padCrop);
    x1 = max(1, min(xx)-padCrop); x2 = min(W, max(xx)+padCrop);
    heatC = heatRGB(y1:y2, x1:x2, :);
else
    heatC = heatRGB;
end
heatC_resized = resize_rgb(heatC, [H W]);          % base-MATLAB resize

%% ---------------------- MAKE ALL PANELS SAME SIZE -----------------------
Iplot            = repmat(I, [1 1 3]);             % left panel as RGB
compRGB_resized  = compRGB;                        % already [H W 3]

%% ---------------------- DISPLAY (3 PANELS) -------------------------------
figure('Name','Original | Detecting Tumour | Percentage of Tumour', ...
       'Color','w','Position',[60 60 1650 600]);

% LEFT: Original (normalized)
subplot(1,3,1);
image(Iplot); axis image off;
title('Original (normalized)');

% CENTER: Detecting Tumour (full color heatmap, borderless)
subplot(1,3,2);
image(heatC_resized); axis image off;
title('Detecting Tumour');

% RIGHT: Percentage of Tumour (negative + orange patch + text)
subplot(1,3,3);
image(compRGB_resized); axis image off;
title('Percentage of Tumour');
hold on;
% filled orange patch over tumour area
if detected && numel(hullX) >= 3
    patch(hullX, hullY, [1 0.5 0], 'FaceAlpha', 0.35, 'EdgeColor','none');  % orange fill
    plot(hullX, hullY, 'w-', 'LineWidth', 1.1);                              % white edge
end
if detected
    y = centroid(1); x = centroid(2);
    th = linspace(0, 2*pi, 300);
    plot(x + eqRadius*cos(th), y + eqRadius*sin(th), 'w', 'LineWidth', 2);
    plot(x, y, 'w+', 'MarkerSize', 10, 'LineWidth', 1.5);
    txt = sprintf('Tumour: %.2f%%  |  Safe: %.2f%%', affectedPercent, safePercent);
else
    txt = sprintf('Tumour: 0.00%% | Safe: 100.00%%');
end
text(10, 20, txt, 'Color','w', 'FontSize',12, 'FontWeight','bold', ...
     'BackgroundColor',[0 0 0 0.35]);
hold off;

%% ---------------------- REPORT ------------------------------------------
fprintf('\n--- Tumour Detection Report ---\n');
fprintf('File: %s | Mode: %s | zThr=%.2f\n', imgPath, sliceType, zThr);
fprintf('Brain area (approx): %d px (central mask)\n', brainArea);
fprintf('Tumour area: %d px\n', tumorArea);
fprintf('Affected: %.2f%% | Safe: %.2f%%\n', affectedPercent, safePercent);

%% ======================= HELPER FUNCTIONS ===============================
function A = load_image_safe(pth)
    try
        A = imread(pth);
    catch
        try
            A = dicomread(pth);
        catch ME
            error('Could not read image: %s\n%s', pth, ME.message);
        end
    end
    if ~isnumeric(A), error('Loaded image is not numeric.'); end
end

function G = to_grayscale_double(A)
    if ndims(A)==3 && size(A,3)>=3
        A = 0.2989*double(A(:,:,1)) + 0.5870*double(A(:,:,2)) + 0.1140*double(A(:,:,3));
    else
        A = double(A);
        if ndims(A) > 2, A = A(:,:,1); end
    end
    G = normalize01(A);
end

function N = normalize01(X)
    X = double(X);
    mn = min(X(:)); mx = max(X(:));
    if mx > mn, N = (X - mn) / (mx - mn);
    else, N = zeros(size(X)); end
end

function K = gaussian_kernel(sigma)
    k = max(3, 2*ceil(3*sigma)+1);
    r = -(k-1)/2:(k-1)/2; [X,Y] = meshgrid(r,r);
    K = exp(-(X.^2 + Y.^2)/(2*sigma^2)); K = K / sum(K(:));
end

function mask = region_from_seed(BW, y0, x0)
    [H,W] = size(BW);
    if ~BW(y0,x0), mask = false(H,W); return; end
    mask = false(H,W); visited = false(H,W);
    qy = zeros(numel(BW),1); qx = zeros(numel(BW),1);
    head = 1; tail = 1; qy(tail)=y0; qx(tail)=x0; tail=tail+1; visited(y0,x0)=true;
    nbr = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    while head < tail
        y = qy(head); x = qx(head); head = head + 1; mask(y,x) = true;
        for k = 1:8
            yy = y + nbr(k,1); xx = x + nbr(k,2);
            if yy>=1 && yy<=H && xx>=1 && xx<=W && ~visited(yy,xx) && BW(yy,xx)
                visited(yy,xx) = true; qy(tail)=yy; qx(tail)=xx; tail=tail+1;
            end
        end
    end
end

function Y = resize_rgb(X, targetSize)
    % Resize truecolor RGB image X to [targetSize(1) targetSize(2)] using interp2.
    [H,W,C] = size(X);
    newH = targetSize(1); newW = targetSize(2);
    [xq, yq] = meshgrid(linspace(1,W,newW), linspace(1,H,newH));
    Y = zeros(newH, newW, C);
    for ch = 1:C
        Y(:,:,ch) = interp2(double(X(:,:,ch)), xq, yq, 'linear', 0);
    end
    Y = max(0, min(1, Y));  % clamp to [0,1]
end