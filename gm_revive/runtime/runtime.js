// GameMaker 8 compatible runtime for HTML5 canvas.
// Implements the subset of the GM8 API used by the converted game (game.js),
// written so it can be extended for other converted projects.
"use strict";

// GameMaker 8 option "treat uninitialized variables as value 0": reading a variable that was never
// assigned yields 0. Implemented with a Proxy at the end of the prototype chain, so normal property
// reads/writes stay fast and only misses hit the trap.
const __UNINIT = new Proxy({}, {
    get: (t, k, recv) => (typeof k === 'symbol' || k === 'then' || k === 'toJSON') ? undefined : 0,
    set: (t, k, v, recv) => { Object.defineProperty(recv, k, { value: v, writable: true, enumerable: true, configurable: true }); return true; },
    has: () => false,
});
const G = Object.create(__UNINIT);   // global.* variables

const B = (() => {
    const B = {};
    // ------------------------------------------------------------------ constants
    const C = {
        c_aqua: 16776960, c_black: 0, c_blue: 16711680, c_dkgray: 4210752, c_fuchsia: 16711935,
        c_gray: 8421504, c_green: 32768, c_lime: 65280, c_ltgray: 12632256, c_maroon: 128,
        c_navy: 8388608, c_olive: 32896, c_orange: 4235519, c_purple: 8388736, c_red: 255,
        c_silver: 12632256, c_teal: 8421376, c_white: 16777215, c_yellow: 65535,
        bm_normal: 0, bm_add: 1, bm_max: 2, bm_subtract: 3,
        bm_zero: 1, bm_one: 2, bm_src_color: 3, bm_inv_src_color: 4, bm_src_alpha: 5,
        bm_inv_src_alpha: 6, bm_dest_alpha: 7, bm_inv_dest_alpha: 8, bm_dest_color: 9,
        bm_inv_dest_color: 10, bm_src_alpha_sat: 11,
        fa_left: 0, fa_center: 1, fa_right: 2, fa_top: 0, fa_middle: 1, fa_bottom: 2,
        pr_pointlist: 1, pr_linelist: 2, pr_linestrip: 3, pr_trianglelist: 4, pr_trianglestrip: 5, pr_trianglefan: 6,
        mb_any: -1, mb_none: 0, mb_left: 1, mb_right: 2, mb_middle: 3,
        vk_nokey: 0, vk_anykey: 1, vk_backspace: 8, vk_tab: 9, vk_enter: 13, vk_shift: 16, vk_control: 17,
        vk_alt: 18, vk_pause: 19, vk_escape: 27, vk_space: 32, vk_pageup: 33, vk_pagedown: 34, vk_end: 35,
        vk_home: 36, vk_left: 37, vk_up: 38, vk_right: 39, vk_down: 40, vk_insert: 45, vk_delete: 46,
        vk_f1: 112, vk_f2: 113, vk_f3: 114, vk_f4: 115, vk_f5: 116, vk_f6: 117, vk_f7: 118, vk_f8: 119,
        vk_f9: 120, vk_f10: 121, vk_f11: 122, vk_f12: 123,
        vk_numpad0: 96, vk_numpad1: 97, vk_numpad2: 98, vk_numpad3: 99, vk_numpad4: 100, vk_numpad5: 101,
        vk_numpad6: 102, vk_numpad7: 103, vk_numpad8: 104, vk_numpad9: 105,
        pi: Math.PI,
    };
    Object.assign(B, C);

    // ------------------------------------------------------------------ state
    const R = B._rt = {
        instances: [],          // all live instances, creation order
        byId: new Map(),
        nextId: 100001,
        room: -1, roomData: null, pendingRoom: null,
        canvas: null, ctx: null, screen: null, sctx: null,
        draw: { color: 0, alpha: 1, font: -1, halign: 0, valign: 0, blend: 'source-over' },
        sprites: [], backgrounds: [], sounds: [], fonts: [],
        dsLists: [], paths: [], surfaces: [],
        keys: new Set(), pressed: new Set(), released: new Set(),
        mouse: { x: 0, y: 0, buttons: new Set(), pressed: new Set(), released: new Set(), wheel: 0 },
        fps: 0, frameCount: 0, fpsTime: 0,
        eventStack: [],
        extraFiles: {},
        surfaceTarget: null,
        prim: null,
        tintCache: new Map(),
        paused: false,
    };
    B.view_xview = [0, 0, 0, 0, 0, 0, 0, 0]; B.view_yview = [0, 0, 0, 0, 0, 0, 0, 0];
    B.view_wview = [640, 640, 640, 640, 640, 640, 640, 640]; B.view_hview = [480, 480, 480, 480, 480, 480, 480, 480];
    B.view_xport = [0, 0, 0, 0, 0, 0, 0, 0]; B.view_yport = [0, 0, 0, 0, 0, 0, 0, 0];
    B.view_wport = [640, 640, 640, 640, 640, 640, 640, 640]; B.view_hport = [480, 480, 480, 480, 480, 480, 480, 480];
    B.view_hborder = [32, 32, 32, 32, 32, 32, 32, 32]; B.view_vborder = [32, 32, 32, 32, 32, 32, 32, 32];
    B.view_object = [-1, -1, -1, -1, -1, -1, -1, -1]; B.view_visible = [false, false, false, false, false, false, false, false];
    B.view_enabled = false; B.view_current = 0;
    B.room_width = 640; B.room_height = 480; B.room_speed = 30; B.room_caption = '';
    B.working_directory = '.'; B.program_directory = '.'; B.temp_directory = '.';
    B.score = 0; B.lives = 0; B.health = 100;
    B.keyboard_key = 0; B.keyboard_lastkey = 0; B.keyboard_lastchar = ''; B.keyboard_string = '';
    Object.defineProperty(B, 'fps', { get: () => R.fps });
    Object.defineProperty(B, 'mouse_x', { get: () => R.mouse.x + B.view_xview[0] });
    Object.defineProperty(B, 'mouse_y', { get: () => R.mouse.y + B.view_yview[0] });
    Object.defineProperty(B, 'room', { get: () => R.room });
    Object.defineProperty(B, 'current_time', { get: () => Math.floor(performance.now()) });
    Object.defineProperty(B, 'instance_count', { get: () => R.instances.length });

    // ------------------------------------------------------------------ helpers
    B.T = v => v > 0.5;
    B.toArr = v => (Array.isArray(v) ? v : []);
    B.toArr2 = (a, i) => { i = Math.round(i); return Array.isArray(a[i]) ? a[i] : (a[i] = []); };
    B.sw = v => (v === true ? 1 : v === false ? 0 : v);
    B.aget = (a, i, j) => {
        if (a == null) return 0;
        let v = a[Math.round(i)];
        if (j !== undefined) v = v == null ? undefined : v[Math.round(j)];
        return v === undefined ? 0 : v;
    };
    const DUMMY = Object.create(__UNINIT);
    B._DUMMY = DUMMY;

    function objIsA(obj, ancestor) {
        while (obj >= 0) {
            if (obj === ancestor) return true;
            obj = OBJECTS[obj] ? OBJECTS[obj].parent : -1;
        }
        return false;
    }
    B._objIsA = objIsA;

    // Per-object instance lists, rebuilt only when instances are created/destroyed.
    // Arrays are never mutated after being handed out, so with() loops keep snapshot semantics.
    R.version = 0; const ofCache = new Map();
    function instancesOf(obj) {
        const c = ofCache.get(obj);
        if (c && c.v === R.version) return c.list;
        const out = [];
        for (const i of R.instances) if (!i.__dead && objIsA(i.object_index, obj)) out.push(i);
        ofCache.set(obj, { v: R.version, list: out });
        return out;
    }

    function resolve(target, self, other) {
        if (target === true) target = 1; else if (target === false) target = 0;
        if (typeof target === 'object' && target) return target.__dead ? [] : [target];
        target = Math.round(target);
        if (target === -1) return self && self.id ? [self] : [];
        if (target === -2) return other && other.id ? [other] : [];
        if (target === -3) return R.instances.filter(i => !i.__dead);
        if (target === -4 || isNaN(target)) return [];
        if (target >= 100000) {
            const i = R.byId.get(target);
            return i && !i.__dead ? [i] : [];
        }
        return instancesOf(target);
    }

    // I(): resolve an id/object index to a single instance (first match), for field access
    B.I = function (target) {
        if (typeof target === 'object' && target) return target;
        target = Math.round(target);
        if (target >= 100000) return R.byId.get(target) || DUMMY;
        if (target >= 0) { const l = instancesOf(target); for (const i of l) if (!i.__dead) return i; }
        return DUMMY;
    };

    B.setField = function (target, name, value) {
        const list = resolve(target, null, null);
        for (const i of list) i[name] = value;
        return value;
    };

    B.with = function* (target, self, other) {
        const list = resolve(target, self, other);
        for (const inst of list) {
            if (inst.__dead) continue;
            yield [inst, self];
        }
    };

    // ------------------------------------------------------------------ Instance
    class InstanceBase { }
    Object.setPrototypeOf(InstanceBase.prototype, __UNINIT);
    class Instance extends InstanceBase {
        constructor(obj, x, y, id) {
            super();
            const o = OBJECTS[obj];
            this.id = id;
            this.object_index = obj;
            this.x = x; this.y = y; this.xstart = x; this.ystart = y; this.xprevious = x; this.yprevious = y;
            this.sprite_index = o.sprite; this.mask_index = o.mask;
            this.image_index = 0; this.image_speed = 1;
            this.image_xscale = 1; this.image_yscale = 1; this.image_angle = 0;
            this.image_blend = 16777215; this.image_alpha = 1;
            this.depth = o.depth; this.visible = o.visible; this.solid = o.solid; this.persistent = o.persistent;
            this.alarm = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
            this.hspeed = 0; this.vspeed = 0; this.friction = 0; this.gravity = 0; this.gravity_direction = 270;
            this.timeline_index = -1; this.timeline_position = 0; this.timeline_speed = 1;
            this.path_index = -1; this.path_position = 0; this.path_speed = 0;
            this.__order = id;
        }
        get speed() { return Math.hypot(this.hspeed, this.vspeed); }
        set speed(v) {
            const d = this.direction * Math.PI / 180;
            this.hspeed = Math.cos(d) * v; this.vspeed = -Math.sin(d) * v;
            if (Math.abs(this.hspeed) < 1e-9) this.hspeed = 0; if (Math.abs(this.vspeed) < 1e-9) this.vspeed = 0;
        }
        get direction() {
            if (this.hspeed === 0 && this.vspeed === 0) return this.__dir || 0;
            let d = Math.atan2(-this.vspeed, this.hspeed) * 180 / Math.PI; if (d < 0) d += 360; return d;
        }
        set direction(v) {
            v = ((v % 360) + 360) % 360; this.__dir = v;
            const s = this.speed, d = v * Math.PI / 180;
            this.hspeed = Math.cos(d) * s; this.vspeed = -Math.sin(d) * s;
            if (Math.abs(this.hspeed) < 1e-9) this.hspeed = 0; if (Math.abs(this.vspeed) < 1e-9) this.vspeed = 0;
        }
        get image_single() { return this.image_speed === 0 ? this.image_index : -1; }
        set image_single(v) {
            if (v < 0) { this.image_speed = 1; }
            else { this.image_index = v; this.image_speed = 0; }
        }
        get image_number() { const s = R.sprites[this.sprite_index]; return s ? s.frames.length : 0; }
        get sprite_width() { const s = R.sprites[this.sprite_index]; return s ? s.width * this.image_xscale : 0; }
        get sprite_height() { const s = R.sprites[this.sprite_index]; return s ? s.height * this.image_yscale : 0; }
        get sprite_xoffset() { const s = R.sprites[this.sprite_index]; return s ? s.xoffset * this.image_xscale : 0; }
        get sprite_yoffset() { const s = R.sprites[this.sprite_index]; return s ? s.yoffset * this.image_yscale : 0; }
        __bbox() {
            const s = R.sprites[this.mask_index >= 0 ? this.mask_index : this.sprite_index];
            if (!s) return null;
            const sx = this.image_xscale, sy = this.image_yscale;
            let l = this.x + (s.bbox.left - s.xoffset) * sx, r = this.x + (s.bbox.right + 1 - s.xoffset) * sx;
            let t = this.y + (s.bbox.top - s.yoffset) * sy, b = this.y + (s.bbox.bottom + 1 - s.yoffset) * sy;
            if (l > r) [l, r] = [r, l]; if (t > b) [t, b] = [b, t];
            return { l, r, t, b };
        }
        get bbox_left() { const b = this.__bbox(); return b ? Math.floor(b.l) : this.x; }
        get bbox_right() { const b = this.__bbox(); return b ? Math.ceil(b.r) - 1 : this.x; }
        get bbox_top() { const b = this.__bbox(); return b ? Math.floor(b.t) : this.y; }
        get bbox_bottom() { const b = this.__bbox(); return b ? Math.ceil(b.b) - 1 : this.y; }
    }
    B._Instance = Instance;

    // ------------------------------------------------------------------ events
    function findHandler(obj, key) {
        while (obj >= 0) {
            const o = OBJECTS[obj];
            if (o && o.events[key]) return obj;
            obj = o ? o.parent : -1;
        }
        return -1;
    }

    function runEvent(inst, key, other) {
        if (inst.__dead && !key.startsWith('destroy')) return false;
        const owner = findHandler(inst.object_index, key);
        if (owner < 0) return false;
        R.eventStack.push([owner, key]);
        try { OBJECTS[owner].events[key](inst, other || inst); }
        finally { R.eventStack.pop(); }
        return true;
    }
    B._runEvent = runEvent;

    B.event_inherited = function (self, other) {
        const top = R.eventStack[R.eventStack.length - 1];
        if (!top) return 0;
        const [owner, key] = top;
        const parent = OBJECTS[owner].parent;
        if (parent < 0) return 0;
        const h = findHandler(parent, key);
        if (h < 0) return 0;
        R.eventStack.push([h, key]);
        try { OBJECTS[h].events[key](self, other); } finally { R.eventStack.pop(); }
        return 0;
    };
    B.event_perform = function (self, type, num) {
        const names = ['create', 'destroy', 'alarm', 'step', 'collision', 'keyboard', 'mouse', 'other', 'draw', 'keypress', 'keyrelease'];
        runEvent(self, names[type] + '_' + num, self); return 0;
    };

    // ------------------------------------------------------------------ instances
    B.instance_create = function (x, y, obj) {
        obj = Math.round(obj);
        if (!OBJECTS[obj]) { console.warn('instance_create: bad object', obj); return -4; }
        const inst = new Instance(obj, x, y, R.nextId++);
        R.instances.push(inst); R.byId.set(inst.id, inst); R.version++;
        runEvent(inst, 'create_0', inst);
        return inst.id;
    };
    B.instance_destroy = function (self) {
        if (!self || self.__dead || self === DUMMY) return 0;
        runEvent(self, 'destroy_0', self);
        killInstance(self);
        return 0;
    };
    function killInstance(inst) {
        inst.__dead = true;
        R.byId.delete(inst.id); R.version++;
        R.needsCompact = true;
    }
    B.instance_exists = function (obj) { return resolve(obj, null, null).length > 0; };
    B.instance_number = function (obj) { return instancesOf(Math.round(obj)).length; };
    B.instance_find = function (obj, n) { const l = resolve(obj, null, null); return l[n] ? l[n].id : -4; };
    B.instance_nearest = function (x, y, obj) {
        let best = -4, bd = Infinity;
        for (const i of resolve(obj, null, null)) { const d = Math.hypot(i.x - x, i.y - y); if (d < bd) { bd = d; best = i.id; } }
        return best;
    };
    B.instance_furthest = function (x, y, obj) {
        let best = -4, bd = -1;
        for (const i of resolve(obj, null, null)) { const d = Math.hypot(i.x - x, i.y - y); if (d > bd) { bd = d; best = i.id; } }
        return best;
    };
    B.instance_position = function (x, y, obj) {
        for (const i of resolve(obj, null, null)) { const b = i.__bbox(); if (b && x >= b.l && x < b.r && y >= b.t && y < b.b) return i.id; }
        return -4;
    };
    B.instance_change = function (self, obj, perf) {
        if (perf) runEvent(self, 'destroy_0', self);
        self.object_index = obj; self.sprite_index = OBJECTS[obj].sprite;
        if (perf) runEvent(self, 'create_0', self);
        return 0;
    };
    B.object_get_sprite = obj => OBJECTS[obj] ? OBJECTS[obj].sprite : -1;
    B.object_get_name = obj => OBJECTS[obj] ? OBJECTS[obj].name : '';
    B.object_get_parent = obj => OBJECTS[obj] ? OBJECTS[obj].parent : -1;
    B.object_is_ancestor = (a, b) => a !== b && objIsA(a, b);
    B.variable_global_exists = name => Object.prototype.hasOwnProperty.call(G, name);
    B.variable_local_exists = (self, name) => Object.prototype.hasOwnProperty.call(self, name);
    B.script_execute = function (self, other, scr, ...args) {
        const sc = SCRIPT_LIST[Math.round(scr)];
        return sc ? sc(self, other, ...args) : 0;
    };
    B.distance_to_point = function (self, x, y) {
        const b = self.__bbox(); if (!b) return Math.hypot(self.x - x, self.y - y);
        const dx = Math.max(b.l - x, 0, x - b.r), dy = Math.max(b.t - y, 0, y - b.b); return Math.hypot(dx, dy);
    };
    B.distance_to_object = function (self, obj) {
        let best = 1e6;
        for (const i of resolve(obj, self, null)) if (i !== self) best = Math.min(best, Math.hypot(i.x - self.x, i.y - self.y));
        return best;
    };
    B.place_meeting = function (self, x, y, obj) {
        const ox = self.x, oy = self.y; self.x = x; self.y = y;
        const a = self.__bbox(); self.x = ox; self.y = oy;
        if (!a) return false;
        for (const i of resolve(obj, self, null)) {
            if (i === self) continue; const b = i.__bbox();
            if (b && a.l < b.r && a.r > b.l && a.t < b.b && a.b > b.t) return true;
        }
        return false;
    };
    B.position_meeting = (x, y, obj) => B.instance_position(x, y, obj) !== -4;
    B.move_towards_point = function (self, x, y, sp) {
        self.hspeed = 0; self.vspeed = 0; self.__dir = B.point_direction(self.x, self.y, x, y);
        self.direction = self.__dir; self.speed = sp; return 0;
    };
    B.motion_set = function (self, dir, sp) { self.speed = 0; self.direction = dir; self.speed = sp; return 0; };
    B.motion_add = function (self, dir, sp) {
        const d = dir * Math.PI / 180; self.hspeed += Math.cos(d) * sp; self.vspeed -= Math.sin(d) * sp; return 0;
    };

    // ------------------------------------------------------------------ math
    B.random = n => Math.random() * n;
    B.random_range = (a, b) => a + Math.random() * (b - a);
    B.irandom = n => Math.floor(Math.random() * (Math.floor(n) + 1));
    B.irandom_range = (a, b) => Math.floor(a + Math.random() * (b - a + 1));
    B.choose = (...a) => a[Math.floor(Math.random() * a.length)];
    B.round = x => { // GM8 (Delphi) rounds half to even
        const f = Math.floor(x), d = x - f;
        if (d > 0.5) return f + 1; if (d < 0.5) return f; return f % 2 === 0 ? f : f + 1;
    };
    B.floor = Math.floor; B.ceil = Math.ceil; B.abs = Math.abs; B.sign = Math.sign; B.sqrt = Math.sqrt;
    B.sqr = x => x * x; B.power = Math.pow; B.exp = Math.exp; B.ln = Math.log; B.log2 = Math.log2; B.log10 = Math.log10;
    B.logn = (n, x) => Math.log(x) / Math.log(n);
    B.sin = Math.sin; B.cos = Math.cos; B.tan = Math.tan; B.arcsin = Math.asin; B.arccos = Math.acos; B.arctan = Math.atan;
    B.arctan2 = Math.atan2; B.frac = x => x - Math.trunc(x);
    B.degtorad = d => d * Math.PI / 180; B.radtodeg = r => r * 180 / Math.PI;
    B.min = (...a) => Math.min(...a); B.max = (...a) => Math.max(...a);
    B.mean = (...a) => a.reduce((s, v) => s + v, 0) / a.length;
    B.median = (...a) => { const s = [...a].sort((x, y) => x - y); return s[Math.floor(s.length / 2)]; };
    B.point_distance = (x1, y1, x2, y2) => Math.hypot(x2 - x1, y2 - y1);
    B.point_direction = (x1, y1, x2, y2) => {
        if (x1 === x2 && y1 === y2) return 0;
        let d = Math.atan2(-(y2 - y1), x2 - x1) * 180 / Math.PI; return d < 0 ? d + 360 : d;
    };
    B.lengthdir_x = (len, dir) => Math.cos(dir * Math.PI / 180) * len;
    B.lengthdir_y = (len, dir) => -Math.sin(dir * Math.PI / 180) * len;
    B.is_string = v => typeof v === 'string';
    B.is_real = v => typeof v !== 'string';
    B.real = v => { const n = parseFloat(v); return isNaN(n) ? 0 : n; };
    B.string = function (v) {
        if (typeof v === 'string') return v;
        if (v === true) return '1'; if (v === false || v == null) return '0';
        if (Number.isInteger(v)) return String(v);
        if (!isFinite(v)) return String(v);
        return v.toFixed(2);
    };
    B.string_format = (v, tot, dec) => { let s = Number(v).toFixed(dec); while (s.length < tot) s = ' ' + s; return s; };
    B.ord = s => String(s).toUpperCase().charCodeAt(0) || 0;
    B.chr = n => String.fromCharCode(n);
    B.string_length = s => String(s).length;
    B.string_char_at = (s, i) => String(s).charAt(i - 1);
    B.string_copy = (s, i, n) => String(s).substr(Math.max(0, i - 1), n);
    B.string_pos = (sub, s) => String(s).indexOf(sub) + 1;
    B.string_delete = (s, i, n) => { s = String(s); return s.slice(0, i - 1) + s.slice(i - 1 + n); };
    B.string_insert = (sub, s, i) => { s = String(s); return s.slice(0, i - 1) + sub + s.slice(i - 1); };
    B.string_replace = (s, a, b) => String(s).replace(a, b);
    B.string_replace_all = (s, a, b) => String(s).split(a).join(b);
    B.string_count = (sub, s) => String(s).split(sub).length - 1;
    B.string_upper = s => String(s).toUpperCase(); B.string_lower = s => String(s).toLowerCase();
    B.string_repeat = (s, n) => String(s).repeat(Math.max(0, n));
    B.string_digits = s => String(s).replace(/[^0-9]/g, '');
    B.date_current_time = () => Date.now() / 86400000 + 25569;
    B.date_current_datetime = B.date_current_time;
    B.show_debug_message = s => { console.log('[GM]', s); return 0; };
    B.show_message = s => { alert(String(s).replace(/#/g, '\n')); return 0; };

    // ------------------------------------------------------------------ colors
    const clampByte = v => Math.max(0, Math.min(255, Math.round(v)));
    B.make_color_rgb = (r, g, b) => clampByte(r) | (clampByte(g) << 8) | (clampByte(b) << 16);
    B.make_colour_rgb = B.make_color_rgb;
    B.color_get_red = c => c & 255; B.color_get_green = c => (c >> 8) & 255; B.color_get_blue = c => (c >> 16) & 255;
    B.merge_color = (a, b, t) => B.make_color_rgb(
        (a & 255) + ((b & 255) - (a & 255)) * t,
        ((a >> 8) & 255) + (((b >> 8) & 255) - ((a >> 8) & 255)) * t,
        ((a >> 16) & 255) + (((b >> 16) & 255) - ((a >> 16) & 255)) * t);
    B.make_color_hsv = (h, s, v) => {
        h = h / 255 * 6; s /= 255; v /= 255;
        const i = Math.floor(h) % 6, f = h - Math.floor(h), p = v * (1 - s), q = v * (1 - f * s), t = v * (1 - (1 - f) * s);
        const [r, g, b] = [[v, t, p], [q, v, p], [p, v, t], [p, q, v], [t, p, v], [v, p, q]][i];
        return B.make_color_rgb(r * 255, g * 255, b * 255);
    };
    function css(c, a) {
        c = Math.round(c) || 0;
        return `rgba(${c & 255},${(c >> 8) & 255},${(c >> 16) & 255},${a === undefined ? 1 : Math.max(0, Math.min(1, a))})`;
    }
    B._css = css;

    // ------------------------------------------------------------------ ds_list
    B.ds_list_create = () => { R.dsLists.push([]); return R.dsLists.length - 1; };
    const L = id => R.dsLists[Math.round(id)] || [];
    B.ds_list_destroy = id => { R.dsLists[Math.round(id)] = null; return 0; };
    B.ds_list_clear = id => { L(id).length = 0; return 0; };
    B.ds_list_exists = id => !!R.dsLists[Math.round(id)];
    B.ds_list_size = id => L(id).length;
    B.ds_list_empty = id => L(id).length === 0;
    B.ds_list_add = (id, ...v) => { L(id).push(...v); return 0; };
    B.ds_list_insert = (id, pos, v) => { L(id).splice(pos, 0, v); return 0; };
    B.ds_list_replace = (id, pos, v) => { const l = L(id); pos = Math.round(pos); if (pos >= 0 && pos < l.length) l[pos] = v; return 0; };
    B.ds_list_delete = (id, pos) => { const l = L(id); pos = Math.round(pos); if (pos >= 0 && pos < l.length) l.splice(pos, 1); return 0; };
    B.ds_list_find_index = (id, v) => L(id).indexOf(v);
    B.ds_list_find_value = (id, pos) => { const v = L(id)[Math.round(pos)]; return v === undefined ? 0 : v; };
    B.ds_list_sort = (id, asc) => {
        L(id).sort((a, b) => (typeof a === 'string' || typeof b === 'string') ? String(a).localeCompare(String(b)) : a - b);
        if (!asc) L(id).reverse(); return 0;
    };
    B.ds_list_shuffle = id => { const l = L(id); for (let i = l.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [l[i], l[j]] = [l[j], l[i]]; } return 0; };
    B.ds_list_copy = (dst, src) => { R.dsLists[dst] = [...L(src)]; return 0; };

    // ------------------------------------------------------------------ paths
    B.path_add = () => { R.paths.push({ points: [], closed: true }); return R.paths.length - 1; };
    const P = id => R.paths[Math.round(id)] || { points: [], closed: false };
    B.path_delete = id => { R.paths[Math.round(id)] = null; return 0; };
    B.path_exists = id => !!R.paths[Math.round(id)];
    B.path_add_point = (id, x, y, sp) => { P(id).points.push({ x, y, sp }); return 0; };
    B.path_clear_points = id => { P(id).points.length = 0; return 0; };
    B.path_set_closed = (id, c) => { P(id).closed = B.T(c); return 0; };
    B.path_get_number = id => P(id).points.length;
    function pathSegs(p) {
        const pts = p.points.slice(); if (p.closed && pts.length > 1) pts.push(pts[0]);
        return pts;
    }
    B.path_get_length = id => {
        const pts = pathSegs(P(id)); let l = 0;
        for (let i = 1; i < pts.length; i++) l += Math.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y);
        return l;
    };
    function pathAt(id, pos) {
        const pts = pathSegs(P(id));
        if (pts.length === 0) return { x: 0, y: 0, sp: 0 };
        if (pts.length === 1) return pts[0];
        pos = Math.max(0, Math.min(1, pos));
        const total = B.path_get_length(id); let target = pos * total;
        for (let i = 1; i < pts.length; i++) {
            const a = pts[i - 1], b = pts[i], seg = Math.hypot(b.x - a.x, b.y - a.y);
            if (target <= seg || i === pts.length - 1) {
                const t = seg > 0 ? Math.min(1, target / seg) : 0;
                return { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t, sp: a.sp + (b.sp - a.sp) * t };
            }
            target -= seg;
        }
        return pts[pts.length - 1];
    }
    B.path_get_x = (id, pos) => pathAt(id, pos).x;
    B.path_get_y = (id, pos) => pathAt(id, pos).y;
    B.path_get_speed = (id, pos) => pathAt(id, pos).sp;
    B.path_get_point_x = (id, n) => (P(id).points[n] || { x: 0 }).x;
    B.path_get_point_y = (id, n) => (P(id).points[n] || { y: 0 }).y;

    // ------------------------------------------------------------------ input
    B.keyboard_check = k => (k === 1 ? R.keys.size > 0 : k === 0 ? R.keys.size === 0 : R.keys.has(Math.round(k)));
    B.keyboard_check_pressed = k => (k === 1 ? R.pressed.size > 0 : R.pressed.has(Math.round(k)));
    B.keyboard_check_released = k => (k === 1 ? R.released.size > 0 : R.released.has(Math.round(k)));
    B.keyboard_check_direct = B.keyboard_check;
    B.keyboard_clear = k => { R.keys.delete(k); return 0; };
    B.io_clear = () => { R.keys.clear(); R.mouse.buttons.clear(); return 0; };
    B.mouse_check_button = b => (b === -1 ? R.mouse.buttons.size > 0 : b === 0 ? R.mouse.buttons.size === 0 : R.mouse.buttons.has(b));
    B.mouse_check_button_pressed = b => (b === -1 ? R.mouse.pressed.size > 0 : R.mouse.pressed.has(b));
    B.mouse_check_button_released = b => (b === -1 ? R.mouse.released.size > 0 : R.mouse.released.has(b));
    B.mouse_clear = b => { R.mouse.buttons.delete(b); return 0; };

    // ------------------------------------------------------------------ rooms
    B.room_restart = () => { R.pendingRoom = R.room; return 0; };
    B.room_goto = r => { R.pendingRoom = r; return 0; };
    B.room_goto_next = () => { R.pendingRoom = R.room + 1; return 0; };
    B.room_goto_previous = () => { R.pendingRoom = R.room - 1; return 0; };
    B.game_restart = () => { location.reload(); return 0; };
    B.game_end = () => { R.ended = true; return 0; };

    function gotoRoom(index) {
        const first = R.room < 0;
        if (!first) {
            for (const i of [...R.instances]) if (!i.__dead) runEvent(i, 'other_5', i);  // room end
            for (const i of R.instances) if (!i.persistent) killInstance(i);
            compact();
        }
        const rm = ROOMS[index];
        R.room = index; R.roomData = rm;
        B.room_width = rm.width; B.room_height = rm.height; B.room_speed = rm.speed; B.room_caption = rm.caption;
        document.title = rm.caption || document.title;
        B.view_enabled = !!rm.views_enabled;
        (rm.views || []).forEach((v, k) => {
            B.view_visible[k] = v.visible; B.view_xview[k] = v.x; B.view_yview[k] = v.y; B.view_wview[k] = v.w;
            B.view_hview[k] = v.h; B.view_xport[k] = v.px; B.view_yport[k] = v.py; B.view_wport[k] = v.pw;
            B.view_hport[k] = v.ph; B.view_hborder[k] = v.hbor; B.view_vborder[k] = v.vbor; B.view_object[k] = v.obj;
        });
        if (!B.view_enabled) { B.view_xview[0] = 0; B.view_yview[0] = 0; B.view_wview[0] = rm.width; B.view_hview[0] = rm.height; }
        resizeCanvas();
        const created = [];
        for (const d of rm.instances) {
            if (!OBJECTS[d.object]) continue;
            const inst = new Instance(d.object, d.x, d.y, d.id);
            R.nextId = Math.max(R.nextId, d.id + 1);
            R.instances.push(inst); R.byId.set(inst.id, inst); R.version++;
            runEvent(inst, 'create_0', inst);
            if (d.code) d.code(inst, inst);
            created.push(inst);
        }
        if (first) for (const i of [...R.instances]) runEvent(i, 'other_2', i);   // game start
        if (rm.code) rm.code(DUMMY, DUMMY);
        for (const i of [...R.instances]) runEvent(i, 'other_4', i);              // room start
    }

    function compact() {
        if (!R.needsCompact) return;
        R.instances = R.instances.filter(i => !i.__dead);
        R.needsCompact = false;
    }

    // ------------------------------------------------------------------ sprites / backgrounds
    function makeCanvas(w, h) {
        const c = document.createElement('canvas'); c.width = Math.max(1, w); c.height = Math.max(1, h); return c;
    }
    B._makeCanvas = makeCanvas;
    B.sprite_exists = s => !!R.sprites[s];
    B.sprite_get_number = s => (R.sprites[s] ? R.sprites[s].frames.length : 0);
    B.sprite_get_width = s => (R.sprites[s] ? R.sprites[s].width : 0);
    B.sprite_get_height = s => (R.sprites[s] ? R.sprites[s].height : 0);
    B.sprite_get_xoffset = s => (R.sprites[s] ? R.sprites[s].xoffset : 0);
    B.sprite_get_yoffset = s => (R.sprites[s] ? R.sprites[s].yoffset : 0);
    B.sprite_get_name = s => (R.sprites[s] ? R.sprites[s].name : '');
    B.sprite_set_offset = (s, x, y) => { const sp = R.sprites[s]; if (sp) { sp.xoffset = x; sp.yoffset = y; } return 0; };
    function intensityAlpha(dstCanvas, srcCanvas) {
        const w = dstCanvas.width, h = dstCanvas.height;
        const tmp = makeCanvas(w, h), t = tmp.getContext('2d');
        t.drawImage(srcCanvas, 0, 0, w, h);
        const sd = t.getImageData(0, 0, w, h).data;
        const dc = dstCanvas.getContext('2d'), dd = dc.getImageData(0, 0, w, h);
        for (let i = 0; i < sd.length; i += 4) {
            dd.data[i + 3] = Math.round((sd[i] + sd[i + 1] + sd[i + 2]) / 3 * sd[i + 3] / 255);
        }
        dc.putImageData(dd, 0, 0);
    }
    B.sprite_set_alpha_from_sprite = (dst, src) => {
        const d = R.sprites[dst], s = R.sprites[src]; if (!d || !s) return 0;
        d.frames = d.frames.map((f, k) => {
            const c = makeCanvas(f.width, f.height); c.getContext('2d').drawImage(f, 0, 0);
            intensityAlpha(c, s.frames[Math.min(k, s.frames.length - 1)]); return c;
        });
        invalidateTint(dst); return 0;
    };
    B.sprite_replace = (ind, fname, imgnumb, precise, transparent, smooth, preload, xo, yo) => {
        const img = R.extraFiles[normFile(fname)];
        const sp = R.sprites[ind]; if (!img || !sp) return 0;
        const n = Math.max(1, Math.round(imgnumb)), fw = Math.floor(img.width / n), fh = img.height;
        sp.frames = [];
        for (let k = 0; k < n; k++) {
            const c = makeCanvas(fw, fh); c.getContext('2d').drawImage(img, k * fw, 0, fw, fh, 0, 0, fw, fh); sp.frames.push(c);
        }
        sp.width = fw; sp.height = fh; sp.bbox = { left: 0, top: 0, right: fw - 1, bottom: fh - 1 };
        if (xo !== undefined) { sp.xoffset = xo; sp.yoffset = yo; }
        invalidateTint(ind); return 0;
    };
    B.background_get_width = b => (R.backgrounds[b] ? R.backgrounds[b].width : 0);
    B.background_get_height = b => (R.backgrounds[b] ? R.backgrounds[b].height : 0);
    B.background_create_color = (w, h, col) => {
        const c = makeCanvas(w, h), x = c.getContext('2d'); x.fillStyle = css(col); x.fillRect(0, 0, w, h);
        R.backgrounds.push({ name: 'bg_created', image: c, width: w, height: h }); return R.backgrounds.length - 1;
    };
    B.background_create_from_surface = (sid, x, y, w, h, removeback, smooth) => {
        const s = R.surfaces[sid]; const c = makeCanvas(w, h);
        if (s) c.getContext('2d').drawImage(s, x, y, w, h, 0, 0, w, h);
        R.backgrounds.push({ name: 'bg_surface', image: c, width: w, height: h }); return R.backgrounds.length - 1;
    };
    B.background_set_alpha_from_background = (dst, src) => {
        const d = R.backgrounds[dst], s = R.backgrounds[src]; if (!d || !s) return 0;
        intensityAlpha(d.image, s.image); d.__tint = null; return 0;
    };
    B.background_delete = b => { R.backgrounds[b] = null; return 0; };

    // ------------------------------------------------------------------ surfaces
    B.surface_create = (w, h) => { R.surfaces.push(makeCanvas(w, h)); return R.surfaces.length - 1; };
    B.surface_free = s => { R.surfaces[s] = null; return 0; };
    B.surface_exists = s => !!R.surfaces[s];
    B.surface_get_width = s => (R.surfaces[s] ? R.surfaces[s].width : 0);
    B.surface_get_height = s => (R.surfaces[s] ? R.surfaces[s].height : 0);
    B.surface_set_target = s => {
        const c = R.surfaces[s]; if (!c) return 0;
        R.surfaceTarget = R.ctx; R.ctx = c.getContext('2d'); R.ctx.setTransform(1, 0, 0, 1, 0, 0); return 0;
    };
    B.surface_reset_target = () => { if (R.surfaceTarget) { R.ctx = R.surfaceTarget; R.surfaceTarget = null; } return 0; };
    B.draw_surface = (s, x, y) => { const c = R.surfaces[s]; if (c) withAlpha(() => R.ctx.drawImage(c, x, y)); return 0; };

    // ------------------------------------------------------------------ drawing
    const D = R.draw;
    function applyBlend() { R.ctx.globalCompositeOperation = D.blend; }
    function withAlpha(fn, alpha) {
        const ctx = R.ctx; ctx.globalAlpha = Math.max(0, Math.min(1, alpha === undefined ? D.alpha : alpha));
        applyBlend(); fn(ctx); ctx.globalAlpha = 1;
    }
    B.draw_set_color = c => { D.color = c; return 0; };
    B.draw_set_colour = B.draw_set_color;
    B.draw_get_color = () => D.color;
    B.draw_set_alpha = a => { D.alpha = a; return 0; };
    B.draw_get_alpha = () => D.alpha;
    B.draw_set_font = f => { D.font = f; return 0; };
    B.draw_set_halign = a => { D.halign = a; return 0; };
    B.draw_set_valign = a => { D.valign = a; return 0; };
    const BLEND = { 0: 'source-over', 1: 'lighter', 2: 'screen', 3: 'difference' };
    B.draw_set_blend_mode = m => { D.blend = BLEND[m] || 'source-over'; return 0; };
    B.draw_set_blend_mode_ext = (src, dst) => {
        // Common GM8 combinations mapped onto canvas composite modes
        if (dst === 2 || dst === 7) D.blend = 'lighter';
        else if (src === 9 || dst === 3) D.blend = 'multiply';
        else D.blend = 'source-over';
        return 0;
    };
    B.draw_clear = c => { const ctx = R.ctx; ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.fillStyle = css(c); ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height); ctx.restore(); return 0; };
    B.draw_clear_alpha = (c, a) => { const ctx = R.ctx; ctx.save(); ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height); ctx.fillStyle = css(c, a); ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height); ctx.restore(); return 0; };
    B.draw_point = (x, y) => { withAlpha(ctx => { ctx.fillStyle = css(D.color); ctx.fillRect(Math.floor(x), Math.floor(y), 1, 1); }); return 0; };
    B.draw_line = (x1, y1, x2, y2) => B.draw_line_color(x1, y1, x2, y2, D.color, D.color);
    B.draw_line_width = (x1, y1, x2, y2, w) => {
        withAlpha(ctx => { ctx.strokeStyle = css(D.color); ctx.lineWidth = w; ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke(); ctx.lineWidth = 1; }); return 0;
    };
    B.draw_line_color = (x1, y1, x2, y2, c1, c2) => {
        withAlpha(ctx => {
            if (c1 === c2) ctx.strokeStyle = css(c1);
            else { const g = ctx.createLinearGradient(x1, y1, x2, y2); g.addColorStop(0, css(c1)); g.addColorStop(1, css(c2)); ctx.strokeStyle = g; }
            ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(x1 + 0.5, y1 + 0.5); ctx.lineTo(x2 + 0.5, y2 + 0.5); ctx.stroke();
        });
        return 0;
    };
    B.draw_rectangle = (x1, y1, x2, y2, outline) => B.draw_rectangle_color(x1, y1, x2, y2, D.color, D.color, D.color, D.color, outline);
    B.draw_rectangle_color = (x1, y1, x2, y2, c1, c2, c3, c4, outline) => {
        if (x1 > x2) [x1, x2] = [x2, x1]; if (y1 > y2) [y1, y2] = [y2, y1];
        withAlpha(ctx => {
            let style = css(c1);
            if (c1 !== c2 || c1 !== c4) { const g = ctx.createLinearGradient(x1, y1, x2, y2); g.addColorStop(0, css(c1)); g.addColorStop(1, css(c3)); style = g; }
            if (B.T(outline)) { ctx.strokeStyle = style; ctx.lineWidth = 1; ctx.strokeRect(Math.floor(x1) + 0.5, Math.floor(y1) + 0.5, Math.floor(x2 - x1), Math.floor(y2 - y1)); }
            else { ctx.fillStyle = style; ctx.fillRect(x1, y1, x2 - x1 + 1, y2 - y1 + 1); }
        });
        return 0;
    };
    B.draw_circle = (x, y, r, outline) => B.draw_circle_color(x, y, r, D.color, D.color, outline);
    B.draw_circle_color = (x, y, r, c1, c2, outline) => {
        if (!(r > 0)) return 0;
        withAlpha(ctx => {
            let style = css(c1);
            if (c1 !== c2) { const g = ctx.createRadialGradient(x, y, 0, x, y, r); g.addColorStop(0, css(c1)); g.addColorStop(1, css(c2)); style = g; }
            ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI * 2);
            if (B.T(outline)) { ctx.strokeStyle = style; ctx.lineWidth = 1; ctx.stroke(); } else { ctx.fillStyle = style; ctx.fill(); }
        });
        return 0;
    };
    B.draw_ellipse = (x1, y1, x2, y2, outline) => {
        withAlpha(ctx => {
            ctx.beginPath(); ctx.ellipse((x1 + x2) / 2, (y1 + y2) / 2, Math.abs(x2 - x1) / 2, Math.abs(y2 - y1) / 2, 0, 0, Math.PI * 2);
            if (B.T(outline)) { ctx.strokeStyle = css(D.color); ctx.stroke(); } else { ctx.fillStyle = css(D.color); ctx.fill(); }
        });
        return 0;
    };
    B.draw_triangle = (x1, y1, x2, y2, x3, y3, outline) => {
        withAlpha(ctx => {
            ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.lineTo(x3, y3); ctx.closePath();
            if (B.T(outline)) { ctx.strokeStyle = css(D.color); ctx.stroke(); } else { ctx.fillStyle = css(D.color); ctx.fill(); }
        });
        return 0;
    };
    B.draw_healthbar = (x1, y1, x2, y2, amount, backcol, mincol, maxcol, dir, showback, showborder) => {
        amount = Math.max(0, Math.min(100, amount || 0));
        if (B.T(showback)) { const c = D.color; D.color = backcol; B.draw_rectangle(x1, y1, x2, y2, false); D.color = c; }
        const col = B.merge_color(mincol, maxcol, amount / 100), f = amount / 100;
        let bx1 = x1, by1 = y1, bx2 = x2, by2 = y2;
        if (dir === 0) bx2 = x1 + (x2 - x1) * f; else if (dir === 1) bx1 = x2 - (x2 - x1) * f;
        else if (dir === 2) by2 = y1 + (y2 - y1) * f; else by1 = y2 - (y2 - y1) * f;
        if (f > 0) { const c = D.color; D.color = col; B.draw_rectangle(bx1, by1, bx2, by2, false); D.color = c; }
        if (B.T(showborder)) { const c = D.color; D.color = 0; B.draw_rectangle(x1, y1, x2, y2, true); D.color = c; }
        return 0;
    };
    B.draw_primitive_begin = kind => { R.prim = { kind, v: [] }; return 0; };
    B.draw_vertex = (x, y) => { if (R.prim) R.prim.v.push({ x, y, c: D.color, a: D.alpha }); return 0; };
    B.draw_vertex_color = (x, y, c, a) => { if (R.prim) R.prim.v.push({ x, y, c, a }); return 0; };
    B.draw_primitive_end = () => {
        const p = R.prim; R.prim = null; if (!p || p.v.length < 2) return 0;
        const ctx = R.ctx; applyBlend();
        const tri = (a, b, c) => {
            const g = ctx.createLinearGradient(a.x, a.y, c.x, c.y);
            g.addColorStop(0, css(a.c, a.a)); g.addColorStop(1, css(c.c, c.a));
            ctx.fillStyle = g; ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.lineTo(c.x, c.y); ctx.closePath(); ctx.fill();
        };
        const v = p.v;
        if (p.kind === 6) for (let i = 1; i < v.length - 1; i++) tri(v[0], v[i], v[i + 1]);
        else if (p.kind === 5) for (let i = 0; i < v.length - 2; i++) tri(v[i], v[i + 1], v[i + 2]);
        else if (p.kind === 4) for (let i = 0; i + 2 < v.length; i += 3) tri(v[i], v[i + 1], v[i + 2]);
        else {
            ctx.lineWidth = 1;
            const seg = (a, b) => { ctx.strokeStyle = css(a.c, a.a); ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.stroke(); };
            if (p.kind === 2) for (let i = 0; i + 1 < v.length; i += 2) seg(v[i], v[i + 1]);
            else if (p.kind === 3) for (let i = 0; i + 1 < v.length; i++) seg(v[i], v[i + 1]);
            else for (const q of v) { ctx.fillStyle = css(q.c, q.a); ctx.fillRect(q.x, q.y, 1, 1); }
        }
        return 0;
    };

    // Tinted copies of sprite frames (GM multiplies the image by the blend color)
    function invalidateTint(spr) { for (const k of [...R.tintCache.keys()]) if (k.startsWith(spr + ':')) R.tintCache.delete(k); }
    function tinted(img, key, col) {
        col = Math.round(col) & 0xffffff;
        if (col === 0xffffff) return img;
        const k = key + ':' + col;
        let c = R.tintCache.get(k);
        if (c) return c;
        if (R.tintCache.size > 4000) R.tintCache.clear();
        c = makeCanvas(img.width, img.height); const x = c.getContext('2d');
        x.drawImage(img, 0, 0);
        x.globalCompositeOperation = 'multiply'; x.fillStyle = css(col); x.fillRect(0, 0, c.width, c.height);
        x.globalCompositeOperation = 'destination-in'; x.drawImage(img, 0, 0);
        R.tintCache.set(k, c); return c;
    }
    function drawImageExt(img, ox, oy, x, y, xs, ys, rot, alpha) {
        const ctx = R.ctx;
        ctx.globalAlpha = Math.max(0, Math.min(1, alpha)); applyBlend();
        if (!rot && xs === 1 && ys === 1) ctx.drawImage(img, x - ox, y - oy);
        else {
            const b = ctx === R.mainCtx ? R.base : IDENT;
            const r = -rot * Math.PI / 180, c = Math.cos(r), s = Math.sin(r);
            // base * translate(x,y) * rotate(r) * scale(xs,ys)
            const a1 = c * xs, b1 = s * xs, c1 = -s * ys, d1 = c * ys;
            ctx.setTransform(b.a * a1 + b.c * b1, b.b * a1 + b.d * b1, b.a * c1 + b.c * d1, b.b * c1 + b.d * d1,
                b.a * x + b.c * y + b.e, b.b * x + b.d * y + b.f);
            ctx.drawImage(img, -ox, -oy);
            ctx.setTransform(b.a, b.b, b.c, b.d, b.e, b.f);
        }
        ctx.globalAlpha = 1;
    }
    const IDENT = { a: 1, b: 0, c: 0, d: 1, e: 0, f: 0 };
    R.base = IDENT;
    function frameOf(sp, sub, self) {
        if (sub < 0 && self) sub = self.image_index;
        const n = sp.frames.length; if (!n) return -1;
        return ((Math.floor(sub) % n) + n) % n;
    }
    B.draw_sprite = (self, spr, sub, x, y) => B.draw_sprite_ext(self, spr, sub, x, y, 1, 1, 0, 16777215, D.alpha);
    B.draw_sprite_ext = (self, spr, sub, x, y, xs, ys, rot, col, alpha) => {
        const sp = R.sprites[Math.round(spr)]; if (!sp) return 0;
        const f = frameOf(sp, sub, self); if (f < 0 || !sp.frames[f]) return 0;
        drawImageExt(tinted(sp.frames[f], spr + ':' + f, col), sp.xoffset, sp.yoffset, x, y, xs, ys, rot, alpha);
        return 0;
    };
    B.draw_sprite_stretched = (self, spr, sub, x, y, w, h) => {
        const sp = R.sprites[Math.round(spr)]; if (!sp) return 0;
        const f = frameOf(sp, sub, self); if (f < 0) return 0;
        withAlpha(ctx => ctx.drawImage(sp.frames[f], x, y, w, h)); return 0;
    };
    B.draw_self = self => B.draw_sprite_ext(self, self.sprite_index, self.image_index, self.x, self.y,
        self.image_xscale, self.image_yscale, self.image_angle, self.image_blend, self.image_alpha);
    B.draw_background = (b, x, y) => B.draw_background_ext(b, x, y, 1, 1, 0, 16777215, D.alpha);
    B.draw_background_ext = (b, x, y, xs, ys, rot, col, alpha) => {
        const bg = R.backgrounds[Math.round(b)]; if (!bg || !bg.image) return 0;
        drawImageExt(tinted(bg.image, 'bg' + b, col), 0, 0, x, y, xs, ys, rot, alpha); return 0;
    };
    B.draw_background_stretched = (b, x, y, w, h) => {
        const bg = R.backgrounds[Math.round(b)]; if (!bg || !bg.image) return 0;
        withAlpha(ctx => ctx.drawImage(bg.image, x, y, w, h)); return 0;
    };
    B.draw_background_part = (b, l, t, w, h, x, y) => {
        const bg = R.backgrounds[Math.round(b)]; if (!bg || !bg.image || w <= 0 || h <= 0) return 0;
        withAlpha(ctx => ctx.drawImage(bg.image, l, t, w, h, x, y, w, h)); return 0;
    };

    // ---- text
    const fontCache = {};
    function fontCss(f) {
        if (fontCache[f]) return fontCache[f];
        return (fontCache[f] = fontCss2(f));
    }
    function fontCss2(f) {
        const fd = R.fonts[f];
        if (!fd) return '12px Arial';
        const px = Math.round(fd.size * 96 / 72);
        return `${fd.italic ? 'italic ' : ''}${fd.bold ? 'bold ' : ''}${px}px "${fd.font}", Arial, sans-serif`;
    }
    function lineHeight(f) { const fd = R.fonts[f]; return fd ? Math.round(fd.size * 96 / 72 * 1.25) : 15; }
    const splitLines = s => B.string(s).replace(/\\#/g, '\u0001').split('#').map(l => l.replace(/\u0001/g, '#'));
    function drawText(x, y, str, col, alpha, sep, w) {
        const ctx = R.ctx; ctx.font = fontCss(D.font);
        ctx.globalAlpha = Math.max(0, Math.min(1, alpha)); applyBlend();
        ctx.fillStyle = css(col); ctx.textBaseline = 'top';
        ctx.textAlign = ['left', 'center', 'right'][D.halign] || 'left';
        let lines = splitLines(str);
        if (w > 0) lines = wrap(ctx, lines, w);
        const lh = sep > 0 ? sep : lineHeight(D.font), total = lh * lines.length;
        let yy = y - (D.valign === 1 ? total / 2 : D.valign === 2 ? total : 0);
        for (const l of lines) { ctx.fillText(l, Math.round(x), Math.round(yy)); yy += lh; }
        ctx.globalAlpha = 1;
        return 0;
    }
    function wrap(ctx, lines, w) {
        const out = [];
        for (const line of lines) {
            let cur = '';
            for (const word of line.split(' ')) {
                const t = cur ? cur + ' ' + word : word;
                if (ctx.measureText(t).width > w && cur) { out.push(cur); cur = word; } else cur = t;
            }
            out.push(cur);
        }
        return out;
    }
    B.draw_text = (x, y, s) => drawText(x, y, s, D.color, D.alpha);
    B.draw_text_ext = (x, y, s, sep, w) => drawText(x, y, s, D.color, D.alpha, sep, w);
    B.draw_text_color = (x, y, s, c1, c2, c3, c4, a) => drawText(x, y, s, c1, a);
    B.draw_text_ext_color = (x, y, s, sep, w, c1, c2, c3, c4, a) => drawText(x, y, s, c1, a, sep, w);
    B.draw_text_transformed = (x, y, s, xs, ys, ang) => {
        const ctx = R.ctx; ctx.save(); ctx.translate(x, y); ctx.rotate(-ang * Math.PI / 180); ctx.scale(xs, ys);
        drawText(0, 0, s, D.color, D.alpha); ctx.restore(); return 0;
    };
    B.string_width = s => {
        const ctx = R.ctx; ctx.font = fontCss(D.font);
        const w = Math.max(...splitLines(s).map(l => ctx.measureText(l).width)); return Math.ceil(w);
    };
    B.string_height = s => splitLines(s).length * lineHeight(D.font);
    B.font_get_name = f => (R.fonts[f] ? R.fonts[f].font : '');

    // ------------------------------------------------------------------ extension packages
    // GM extension code isn't stored in the project file, so each one needs a hand-written replacement.
    // List them here so the converter/report know they're covered.
    B._extensions = ['WinSkin'];

    // WinSkin (RPG-Maker style window skins)
    const WS = { alpha: 0.4, alpha2: 0.7, back: -1 };
    B.winskin_init = (a1, a2, f1, f2, back) => { WS.alpha = a1; WS.alpha2 = a2; WS.back = back; return 0; };
    B.winskin_step = () => 0;
    B.draw_window_skinned = (x1, y1, x2, y2) => {
        const bg = R.backgrounds[WS.back]; if (!bg || !bg.image) return 0;
        const img = bg.image, ctx = R.ctx;
        x1 = Math.round(x1); y1 = Math.round(y1); x2 = Math.round(x2); y2 = Math.round(y2);
        const w = x2 - x1, h = y2 - y1; if (w <= 0 || h <= 0) return 0;
        ctx.save(); ctx.globalCompositeOperation = 'source-over';
        ctx.globalAlpha = WS.alpha2;
        ctx.drawImage(img, 0, 0, 128, 128, x1 + 2, y1 + 2, w - 4, h - 4);
        ctx.globalAlpha = 1;
        const c = 16, fx = 128, fy = 0, fs = 64;
        // corners
        ctx.drawImage(img, fx, fy, c, c, x1, y1, c, c);
        ctx.drawImage(img, fx + fs - c, fy, c, c, x2 - c, y1, c, c);
        ctx.drawImage(img, fx, fy + fs - c, c, c, x1, y2 - c, c, c);
        ctx.drawImage(img, fx + fs - c, fy + fs - c, c, c, x2 - c, y2 - c, c, c);
        // edges
        if (w > 2 * c) {
            ctx.drawImage(img, fx + c, fy, fs - 2 * c, c, x1 + c, y1, w - 2 * c, c);
            ctx.drawImage(img, fx + c, fy + fs - c, fs - 2 * c, c, x1 + c, y2 - c, w - 2 * c, c);
        }
        if (h > 2 * c) {
            ctx.drawImage(img, fx, fy + c, c, fs - 2 * c, x1, y1 + c, c, h - 2 * c);
            ctx.drawImage(img, fx + fs - c, fy + c, c, fs - 2 * c, x2 - c, y1 + c, c, h - 2 * c);
        }
        ctx.restore();
        return 0;
    };

    // ------------------------------------------------------------------ sound
    let audioUnlocked = false;
    function soundObj(i) { return R.sounds[Math.round(i)]; }
    function makeAudio(snd) {
        if (!snd.url) return null;
        const a = new Audio(snd.url); a.volume = Math.max(0, Math.min(1, snd.volume == null ? 1 : snd.volume)); return a;
    }
    function play(i, loop) {
        const snd = soundObj(i); if (!snd || !snd.url) return 0;
        snd.playing = snd.playing.filter(a => !a.ended && !a.paused);
        if (snd.kind !== 0) { snd.playing.forEach(a => a.pause()); snd.playing = []; }  // music: single channel
        const a = makeAudio(snd); a.loop = !!loop;
        const p = a.play(); if (p && p.catch) p.catch(() => { });
        snd.playing.push(a);
        return 0;
    }
    B.sound_play = i => play(i, false);
    B.sound_loop = i => play(i, true);
    B.sound_stop = i => { const s = soundObj(i); if (s) { s.playing.forEach(a => a.pause()); s.playing = []; } return 0; };
    B.sound_stop_all = () => { R.sounds.forEach(s => { if (s) { s.playing.forEach(a => a.pause()); s.playing = []; } }); return 0; };
    B.sound_isplaying = i => { const s = soundObj(i); return !!s && s.playing.some(a => !a.ended && !a.paused); };
    B.sound_volume = (i, v) => { const s = soundObj(i); if (s) { s.volume = v; s.playing.forEach(a => a.volume = v); } return 0; };
    B.sound_global_volume = v => 0;
    B.sound_replace = (i, fname, kind, preload) => {
        const s = soundObj(i), url = R.extraFiles[normFile(fname)]; if (!s || !url) return 0;
        B.sound_stop(i); s.url = url; s.kind = kind === 3 ? 1 : kind; return 0;
    };

    // ------------------------------------------------------------------ files (bundled extra files next to the game)
    function normFile(f) { return String(f).replace(/\\/g, '/').replace(/^(\.?\/)+/, '').toLowerCase(); }
    B.file_exists = f => normFile(f) in R.extraFiles;

    // ------------------------------------------------------------------ game info (show_info)
    B.show_info = () => {
        const el = document.getElementById('gm-info'); if (!el) return 0;
        el.style.display = el.style.display === 'block' ? 'none' : 'block'; return 0;
    };

    // ------------------------------------------------------------------ main loop
    function resizeCanvas() {
        const w = B.view_enabled ? B.view_wport[0] : B.room_width, h = B.view_enabled ? B.view_hport[0] : B.room_height;
        if (R.canvas.width !== w || R.canvas.height !== h) { R.canvas.width = w; R.canvas.height = h; }
    }

    function updateView() {
        if (!B.view_enabled) return;
        const o = B.view_object[0];
        if (o === -4 || o === -1 || o == null) return;
        const t = B.I(o); if (t === DUMMY) return;
        const w = B.view_wview[0], h = B.view_hview[0], hb = B.view_hborder[0], vb = B.view_vborder[0];
        let vx = B.view_xview[0], vy = B.view_yview[0];
        if (t.x - vx < hb) vx = t.x - hb; if (vx + w - t.x < hb) vx = t.x + hb - w;
        if (t.y - vy < vb) vy = t.y - vb; if (vy + h - t.y < vb) vy = t.y + vb - h;
        B.view_xview[0] = Math.max(0, Math.min(B.room_width - w, vx));
        B.view_yview[0] = Math.max(0, Math.min(B.room_height - h, vy));
    }

    function forEachLive(fn) {
        for (const i of [...R.instances]) if (!i.__dead) fn(i);
    }

    const MOUSE_EV = { 1: [0, 4, 7, 50, 53, 56], 2: [1, 5, 8, 51, 54, 57], 3: [2, 6, 9, 52, 55, 58] };
    function underMouse(inst) {
        const b = inst.__bbox(); if (!b) return false;
        const mx = B.mouse_x, my = B.mouse_y;
        return mx >= b.l && mx < b.r && my >= b.t && my < b.b;
    }

    // Collision events use bounding boxes (GM's precise per-pixel masks are not emulated).
    function collisionTargets(obj) {
        let out = OBJECTS[obj] && OBJECTS[obj].__coll;
        if (out) return out;
        out = [];
        const seen = new Set();
        for (let o = obj; o >= 0 && OBJECTS[o]; o = OBJECTS[o].parent) {
            for (const k of Object.keys(OBJECTS[o].events)) {
                if (!k.startsWith('collision_')) continue;
                const t = +k.slice(10);
                if (!seen.has(t)) { seen.add(t); out.push(t); }
            }
        }
        return (OBJECTS[obj].__coll = out);
    }
    function collisions() {
        forEachLive(a => {
            const targets = collisionTargets(a.object_index);
            if (!targets.length) return;
            for (const t of targets) {
                for (const b of instancesOf(t)) {
                    if (b === a || b.__dead || a.__dead) continue;
                    const p = a.__bbox(), q = b.__bbox();
                    if (!p || !q || !(p.l < q.r && p.r > q.l && p.t < q.b && p.b > q.t)) continue;
                    if (a.solid || b.solid) { a.x = a.xprevious; a.y = a.yprevious; }
                    runEvent(a, 'collision_' + t, b);
                }
            }
        });
    }

    function step() {
        const keysDown = [...R.keys], pressed = [...R.pressed], released = [...R.released];
        const m = R.mouse;
        forEachLive(i => runEvent(i, 'step_1', i));                               // begin step
        forEachLive(i => {                                                         // alarms
            for (let a = 0; a < 12; a++) {
                if (i.alarm[a] > 0) {
                    i.alarm[a] = Math.round(i.alarm[a]) - 1;
                    if (i.alarm[a] === 0) { i.alarm[a] = -1; runEvent(i, 'alarm_' + a, i); if (i.__dead) return; }
                }
            }
        });
        forEachLive(i => {                                                         // keyboard
            for (const k of keysDown) runEvent(i, 'keyboard_' + k, i);
            if (keysDown.length) runEvent(i, 'keyboard_1', i); else runEvent(i, 'keyboard_0', i);
            for (const k of pressed) runEvent(i, 'keypress_' + k, i);
            if (pressed.length) runEvent(i, 'keypress_1', i);
            for (const k of released) runEvent(i, 'keyrelease_' + k, i);
            if (released.length) runEvent(i, 'keyrelease_1', i);
        });
        forEachLive(i => {                                                         // mouse
            const over = underMouse(i);
            for (const b of [1, 2, 3]) {
                const ev = MOUSE_EV[b];
                if (m.buttons.has(b)) { if (over) runEvent(i, 'mouse_' + ev[0], i); runEvent(i, 'mouse_' + ev[3], i); }
                if (m.pressed.has(b)) { if (over) runEvent(i, 'mouse_' + ev[1], i); runEvent(i, 'mouse_' + ev[4], i); }
                if (m.released.has(b)) { if (over) runEvent(i, 'mouse_' + ev[2], i); runEvent(i, 'mouse_' + ev[5], i); }
            }
            if (over && !i.__over) runEvent(i, 'mouse_10', i);
            if (!over && i.__over) runEvent(i, 'mouse_11', i);
            i.__over = over;
            if (m.wheel < 0) runEvent(i, 'mouse_60', i); else if (m.wheel > 0) runEvent(i, 'mouse_61', i);
        });
        forEachLive(i => runEvent(i, 'step_0', i));                               // step
        forEachLive(i => {                                                         // timelines
            if (i.timeline_index < 0 || !TIMELINES[i.timeline_index]) return;
            const tl = TIMELINES[i.timeline_index], from = i.timeline_position, to = from + i.timeline_speed;
            for (const k of Object.keys(tl.moments).map(Number).sort((a, b) => a - b)) {
                if (k >= from && k < to) { tl.moments[k](i, i); if (i.__dead) return; }
            }
            i.timeline_position = to;
        });
        forEachLive(i => {                                                         // motion
            i.xprevious = i.x; i.yprevious = i.y;
            if (i.friction) {
                const s = i.speed; if (s > 0) i.speed = Math.max(0, s - i.friction);
            }
            if (i.gravity) { const d = i.gravity_direction * Math.PI / 180; i.hspeed += Math.cos(d) * i.gravity; i.vspeed -= Math.sin(d) * i.gravity; }
            if (i.hspeed || i.vspeed) { i.x += i.hspeed; i.y += i.vspeed; }
        });
        collisions();                                                              // collision events
        forEachLive(i => runEvent(i, 'step_2', i));                               // end step
        forEachLive(i => {                                                         // animation
            const n = i.image_number; if (!n) return;
            i.image_index += i.image_speed;
            if (i.image_index >= n) { i.image_index -= n; runEvent(i, 'other_7', i); }
            else if (i.image_index < 0) { i.image_index += n; runEvent(i, 'other_7', i); }
        });
        compact();
        R.pressed.clear(); R.released.clear(); m.pressed.clear(); m.released.clear(); m.wheel = 0;
    }

    function draw() {
        const ctx = R.ctx;
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.globalCompositeOperation = 'source-over'; ctx.globalAlpha = 1;
        ctx.fillStyle = R.roomData.draw_color ? css(R.roomData.color) : '#000'; ctx.fillRect(0, 0, R.canvas.width, R.canvas.height);
        updateView();
        if (B.view_enabled) {
            const sx = B.view_wport[0] / B.view_wview[0], sy = B.view_hport[0] / B.view_hview[0];
            ctx.setTransform(sx, 0, 0, sy, -B.view_xview[0] * sx, -B.view_yview[0] * sy);
            R.base = { a: sx, b: 0, c: 0, d: sy, e: -B.view_xview[0] * sx, f: -B.view_yview[0] * sy };
        } else R.base = IDENT;
        drawRoomBackgrounds(false);
        const list = R.instances.filter(i => !i.__dead && i.visible);
        for (const t of R.roomData.tiles || []) list.push(t.__d || (t.__d = { __tile: t, depth: t.depth, __order: -1 }));
        list.sort((a, b) => (b.depth - a.depth) || (a.__order - b.__order));
        for (const i of list) {
            if (i.__tile) {
                const t = i.__tile, bg = R.backgrounds[t.bg];
                if (bg && bg.image) { ctx.globalAlpha = 1; ctx.globalCompositeOperation = 'source-over'; ctx.drawImage(bg.image, t.tx, t.ty, t.w, t.h, t.x, t.y, t.w, t.h); }
                continue;
            }
            if (i.__dead) continue;
            if (!runEvent(i, 'draw_0', i)) {
                if (i.sprite_index >= 0) B.draw_self(i);
            }
            R.ctx = ctx; R.surfaceTarget = null;
        }
        drawRoomBackgrounds(true);
        ctx.setTransform(1, 0, 0, 1, 0, 0);
    }

    function drawRoomBackgrounds(fore) {
        const ctx = R.ctx;
        for (const rb of R.roomData.backgrounds || []) {
            if (!rb.visible || rb.foreground !== fore) continue;
            const bg = R.backgrounds[rb.index]; if (!bg || !bg.image) continue;
            rb.__x = (rb.__x ?? rb.x) + rb.hspeed; rb.__y = (rb.__y ?? rb.y) + rb.vspeed;
            ctx.globalAlpha = 1; ctx.globalCompositeOperation = 'source-over';
            if (rb.stretch) { ctx.drawImage(bg.image, 0, 0, B.room_width, B.room_height); continue; }
            const w = bg.width, h = bg.height;
            let x0 = rb.__x, y0 = rb.__y;
            if (rb.htiled) x0 = ((x0 % w) + w) % w - w;
            if (rb.vtiled) y0 = ((y0 % h) + h) % h - h;
            for (let x = x0; x < B.room_width; x += w) {
                for (let y = y0; y < B.room_height; y += h) {
                    ctx.drawImage(bg.image, Math.round(x), Math.round(y));
                    if (!rb.vtiled) break;
                }
                if (!rb.htiled) break;
            }
        }
    }

    function frame() {
        if (R.pendingRoom !== null) { const r = R.pendingRoom; R.pendingRoom = null; gotoRoom(r); }
        if (R.ended) return;
        try { step(); draw(); }
        catch (e) { reportError(e); throw e; }
        R.frameCount++;
    }

    function reportError(e) {
        console.error(e);
        const el = document.getElementById('gm-error');
        if (el) { el.style.display = 'block'; el.textContent = 'Runtime error: ' + (e && e.stack || e); }
    }

    B._start = function () {
        R.canvas = document.getElementById('gm-canvas');
        R.ctx = R.mainCtx = R.canvas.getContext('2d');
        // inputs
        const keyCode = e => {
            if (e.keyCode) return e.keyCode;
            return 0;
        };
        window.addEventListener('keydown', e => {
            const k = keyCode(e); if (!k) return;
            if ((k >= 112 && k <= 123) || (k >= 37 && k <= 40) || k === 32) e.preventDefault();
            if (!R.keys.has(k)) R.pressed.add(k);
            R.keys.add(k); B.keyboard_key = k; B.keyboard_lastkey = k;
        });
        window.addEventListener('keyup', e => {
            const k = keyCode(e); if (!k) return; e.preventDefault();
            R.keys.delete(k); R.released.add(k); B.keyboard_key = 0;
        });
        window.addEventListener('blur', () => R.keys.clear());
        const btn = e => (e.button === 0 ? 1 : e.button === 2 ? 2 : 3);
        const pos = e => {
            const r = R.canvas.getBoundingClientRect();
            const vw = B.view_enabled ? B.view_wview[0] : R.canvas.width, vh = B.view_enabled ? B.view_hview[0] : R.canvas.height;
            R.mouse.x = (e.clientX - r.left) * vw / r.width; R.mouse.y = (e.clientY - r.top) * vh / r.height;
        };
        R.canvas.addEventListener('mousemove', pos);
        R.canvas.addEventListener('mousedown', e => { pos(e); const b = btn(e); R.mouse.buttons.add(b); R.mouse.pressed.add(b); e.preventDefault(); });
        window.addEventListener('mouseup', e => { pos(e); const b = btn(e); if (R.mouse.buttons.has(b)) { R.mouse.buttons.delete(b); R.mouse.released.add(b); } });
        R.canvas.addEventListener('contextmenu', e => e.preventDefault());
        R.canvas.addEventListener('wheel', e => { R.mouse.wheel = Math.sign(e.deltaY); e.preventDefault(); }, { passive: false });

        gotoRoom(0);
        // fixed-rate loop at room_speed
        let last = performance.now(), acc = 0;
        R.fpsTime = last; let frames = 0;
        const loop = now => {
            if (R.ended) return;
            const dt = Math.min(250, now - last); last = now; acc += dt;
            const stepMs = 1000 / B.room_speed;
            let n = 0;
            while (acc >= stepMs && n < 4) { frame(); acc -= stepMs; n++; frames++; }
            if (n === 4) acc = 0;
            if (now - R.fpsTime >= 1000) { R.fps = Math.round(frames * 1000 / (now - R.fpsTime)); frames = 0; R.fpsTime = now; }
            requestAnimationFrame(loop);
        };
        R.fps = B.room_speed;
        requestAnimationFrame(loop);
    };
    // manual stepping, used for automated testing
    B._frame = frame;
    B._gotoRoom = gotoRoom;
    B._resolve = resolve;

    // ------------------------------------------------------------------ asset loading
    B._load = async function (onProgress) {
        const loadImg = src => new Promise((res, rej) => {
            const im = new Image(); im.onload = () => res(im); im.onerror = () => rej(new Error('failed to load ' + src));
            im.src = (typeof IMAGE_DATA !== 'undefined' && IMAGE_DATA[src]) || src;
        });
        const jobs = [];
        let done = 0, total = 0;
        const track = p => { total++; return p.then(v => { done++; onProgress && onProgress(done / total); return v; }); };
        R.sprites = ASSETS.sprites.map(s => s && { ...s, bbox: { ...s.bbox }, frames: [] });
        ASSETS.sprites.forEach((s, k) => {
            if (!s) return;
            s.frames.forEach((f, j) => {
                if (!f) { R.sprites[k].frames[j] = makeCanvas(1, 1); return; }
                jobs.push(track(loadImg(f)).then(im => { R.sprites[k].frames[j] = im; }));
            });
        });
        R.backgrounds = ASSETS.backgrounds.map(b => b && { ...b, image: null });
        ASSETS.backgrounds.forEach((b, k) => {
            if (b && b.file) jobs.push(track(loadImg(b.file)).then(im => { R.backgrounds[k].image = im; }));
        });
        R.sounds = ASSETS.sounds.map(s => s && { ...s, url: s.play_file || null, playing: [] });
        R.fonts = ASSETS.fonts;
        R.paths = (typeof PATHS !== 'undefined' ? PATHS : []).map(p => p && { points: p.points.map(q => ({ ...q })), closed: p.closed });
        for (const f of (typeof EXTRA_FILES !== 'undefined' ? EXTRA_FILES : [])) {
            const key = normFile(f);
            if (/\.(png|jpe?g|gif|bmp)$/i.test(f)) jobs.push(track(loadImg('files/' + f)).then(im => { R.extraFiles[key] = im; }));
            else R.extraFiles[key] = 'files/' + f;
        }
        await Promise.all(jobs);
    };

    return B;
})();

const I = B.I;
