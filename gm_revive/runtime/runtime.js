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
        ev_create: 0, ev_destroy: 1, ev_alarm: 2, ev_step: 3, ev_collision: 4, ev_keyboard: 5, ev_mouse: 6,
        ev_other: 7, ev_draw: 8, ev_keypress: 9, ev_keyrelease: 10, ev_trigger: 11,
        ev_step_normal: 0, ev_step_begin: 1, ev_step_end: 2,
        ev_outside: 0, ev_boundary: 1, ev_game_start: 2, ev_game_end: 3, ev_room_start: 4, ev_room_end: 5,
        ev_no_more_lives: 6, ev_animation_end: 7, ev_end_of_path: 8, ev_no_more_health: 9,
        ev_user0: 10, ev_user1: 11, ev_user2: 12, ev_user3: 13, ev_user4: 14, ev_user5: 15, ev_user6: 16, ev_user7: 17,
        ev_user8: 18, ev_user9: 19, ev_user10: 20, ev_user11: 21, ev_user12: 22, ev_user13: 23, ev_user14: 24, ev_user15: 25,
        ev_left_button: 0, ev_right_button: 1, ev_middle_button: 2, ev_no_button: 3, ev_left_press: 4, ev_right_press: 5,
        ev_middle_press: 6, ev_left_release: 7, ev_right_release: 8, ev_middle_release: 9, ev_mouse_enter: 10,
        ev_mouse_leave: 11, ev_global_left_button: 50, ev_global_right_button: 51, ev_global_middle_button: 52,
        ev_global_left_press: 53, ev_global_right_press: 54, ev_global_middle_press: 55, ev_global_left_release: 56,
        ev_global_right_release: 57, ev_global_middle_release: 58,
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
    B.score = 0; B.transition_kind = 0; B.transition_steps = 80;
    let lives = -1, health = 100;
    Object.defineProperty(B, 'lives', { get: () => lives, set: v => { if (v <= 0 && lives > 0) R.noMoreLives = true; lives = v; } });
    Object.defineProperty(B, 'health', { get: () => health, set: v => { if (v <= 0 && health > 0) R.noMoreHealth = true; health = v; } });
    B.show_score = false; B.show_lives = false; B.show_health = false;
    B.caption_score = 'Score: '; B.caption_lives = 'Lives: '; B.caption_health = 'Health: ';
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

    // ------------------------------------------------------------------ blocking dialogs
    // GameMaker's show_menu / get_integer / show_question block until the player answers. Browsers
    // can't block, so the first call throws ModalSuspend; the game pauses and shows the dialog, and
    // when the player answers, the interrupted event is run again from the start with the answer
    // returned from that call. (Code before the dialog runs twice, which is harmless for the usual
    // "read state, ask, act" pattern.) show_message just pauses the game until it is dismissed.
    class ModalSuspend { constructor(req) { this.req = req; this.origin = null; } }
    R.replay = null; R.modal = null; R.messages = [];
    function ask(req) {
        const rp = R.replay;
        if (rp && rp.idx < rp.answers.length) return rp.answers[rp.idx++];
        throw new ModalSuspend(req);
    }
    B._ask = ask;

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
        catch (e) {
            if (e instanceof ModalSuspend && R.eventStack.length === 1 && !e.origin) e.origin = { inst, key, other: other || inst };
            throw e;
        }
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
    B.event_user = function (self, n) { runEvent(self, 'other_' + (10 + Math.round(n)), self); return 0; };
    B.event_perform_object = function (self, obj, type, num) {
        const names = ['create', 'destroy', 'alarm', 'step', 'collision', 'keyboard', 'mouse', 'other', 'draw', 'keypress', 'keyrelease'];
        const key = names[type] + '_' + num, h = findHandler(obj, key);
        if (h >= 0) { R.eventStack.push([h, key]); try { OBJECTS[h].events[key](self, self); } finally { R.eventStack.pop(); } }
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
        // ties go to the most recently created instance, as in GameMaker (games such as Ball Attak rely on it)
        for (const i of resolve(obj, null, null)) { const d = Math.hypot(i.x - x, i.y - y); if (d <= bd) { bd = d; best = i.id; } }
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
    // Distance between bounding boxes (inclusive pixel coordinates, like GameMaker): 0 when they overlap
    function bboxGap(a, b) {
        const al = a.bbox_left, ar = a.bbox_right, at = a.bbox_top, ab = a.bbox_bottom;
        const bl = b.bbox_left, br = b.bbox_right, bt = b.bbox_top, bb = b.bbox_bottom;
        const dx = al > br ? al - br : bl > ar ? bl - ar : 0;
        const dy = at > bb ? at - bb : bt > ab ? bt - ab : 0;
        return Math.hypot(dx, dy);
    }
    B.distance_to_object = function (self, obj) {
        let best = 1000000;
        for (const i of resolve(obj, self, null)) if (i !== self) best = Math.min(best, bboxGap(self, i));
        return best;
    };
    function meetsAt(self, x, y, test) {
        const ox = self.x, oy = self.y; self.x = x; self.y = y;
        const a = self.__bbox(); self.x = ox; self.y = oy;
        if (!a) return false;
        for (const i of R.instances) {
            if (i === self || i.__dead || !test(i)) continue; const b = i.__bbox();
            if (b && a.l < b.r && a.r > b.l && a.t < b.b && a.b > b.t) return true;
        }
        return false;
    }
    B.place_free = (self, x, y) => !meetsAt(self, x, y, i => i.solid);
    B.place_empty = (self, x, y) => !meetsAt(self, x, y, () => true);
    function bounce(self, test) {
        const hs = self.hspeed, vs = self.vspeed;
        const hit = (x, y) => meetsAt(self, x, y, test);
        if (!hit(self.x + hs, self.y + vs)) return 0;
        const hb = hit(self.x + hs, self.y), vb = hit(self.x, self.y + vs);
        if (hb) self.hspeed = -hs;
        if (vb) self.vspeed = -vs;
        if (!hb && !vb) { self.hspeed = -hs; self.vspeed = -vs; }
        return 0;
    }
    B.move_bounce_solid = (self, adv) => bounce(self, i => i.solid);
    B.move_bounce_all = (self, adv) => bounce(self, () => true);
    function contact(self, dir, maxd, test) {
        const dx = Math.cos(dir * Math.PI / 180), dy = -Math.sin(dir * Math.PI / 180);
        if (!(maxd > 0)) maxd = 1000;
        if (meetsAt(self, self.x, self.y, test)) return 0;
        for (let k = 0; k < maxd; k++) {
            if (meetsAt(self, self.x + dx, self.y + dy, test)) break;
            self.x += dx; self.y += dy;
        }
        return 0;
    }
    B.move_contact_solid = (self, dir, maxd) => contact(self, dir, maxd, i => i.solid);
    B.move_contact_all = (self, dir, maxd) => contact(self, dir, maxd, () => true);
    function outside(self, dir, maxd, test) {
        const dx = Math.cos(dir * Math.PI / 180), dy = -Math.sin(dir * Math.PI / 180);
        if (!(maxd > 0)) maxd = 1000;
        for (let k = 0; k < maxd && meetsAt(self, self.x, self.y, test); k++) { self.x += dx; self.y += dy; }
        return 0;
    }
    B.move_outside_solid = (self, dir, maxd) => outside(self, dir, maxd, i => i.solid);
    B.move_outside_all = (self, dir, maxd) => outside(self, dir, maxd, () => true);
    B.move_snap = (self, h, v) => { if (h > 0) self.x = Math.round(self.x / h) * h; if (v > 0) self.y = Math.round(self.y / v) * v; return 0; };
    B.move_wrap = (self, hor, vert, margin) => {
        if (B.T(hor)) { if (self.x < -margin) self.x += B.room_width + 2 * margin; else if (self.x > B.room_width + margin) self.x -= B.room_width + 2 * margin; }
        if (B.T(vert)) { if (self.y < -margin) self.y += B.room_height + 2 * margin; else if (self.y > B.room_height + margin) self.y -= B.room_height + 2 * margin; }
        return 0;
    };
    B.move_random = (self, h, v) => {
        for (let k = 0; k < 100; k++) {
            let x = Math.random() * B.room_width, y = Math.random() * B.room_height;
            if (h > 0) x = Math.floor(x / h) * h; if (v > 0) y = Math.floor(y / v) * v;
            if (B.place_free(self, x, y)) { self.x = x; self.y = y; break; }
        }
        return 0;
    };
    B.withAll = (target, self, other, fn) => {
        const list = resolve(target, self, other); if (!list.length) return false;
        for (const i of list) if (!B.T(fn(i, self))) return false;
        return true;
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
    function rectHits(self, l, t, rr, b, obj, notme) {
        if (l > rr) [l, rr] = [rr, l]; if (t > b) [t, b] = [b, t];
        for (const i of resolve(obj, self, null)) {
            if (notme && i === self) continue; const q = i.__bbox();
            if (q && l <= q.r - 1 && rr >= q.l && t <= q.b - 1 && b >= q.t) return i.id;
        }
        return -4;
    }
    B.collision_rectangle = (self, x1, y1, x2, y2, obj, prec, notme) => rectHits(self, x1, y1, x2, y2, obj, B.T(notme));
    B.collision_point = (self, x, y, obj, prec, notme) => rectHits(self, x, y, x, y, obj, B.T(notme));
    B.collision_circle = (self, x, y, rad, obj, prec, notme) => {
        for (const i of resolve(obj, self, null)) {
            if (B.T(notme) && i === self) continue; const q = i.__bbox(); if (!q) continue;
            const dx = Math.max(q.l - x, 0, x - q.r), dy = Math.max(q.t - y, 0, y - q.b);
            if (dx * dx + dy * dy <= rad * rad) return i.id;
        }
        return -4;
    };
    B.collision_line = (self, x1, y1, x2, y2, obj, prec, notme) => {
        const steps = Math.max(1, Math.ceil(Math.hypot(x2 - x1, y2 - y1)));
        for (const i of resolve(obj, self, null)) {
            if (B.T(notme) && i === self) continue; const q = i.__bbox(); if (!q) continue;
            for (let k = 0; k <= steps; k++) {
                const px = x1 + (x2 - x1) * k / steps, py = y1 + (y2 - y1) * k / steps;
                if (px >= q.l && px < q.r && py >= q.t && py < q.b) return i.id;
            }
        }
        return -4;
    };
    B.collision_ellipse = (self, x1, y1, x2, y2, obj, prec, notme) => rectHits(self, x1, y1, x2, y2, obj, B.T(notme));
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

    // ------------------------------------------------------------------ ds_grid
    R.grids = [];
    const GR = id => R.grids[Math.round(id)];
    B.ds_grid_create = (w, h) => { w = Math.max(0, Math.round(w)); h = Math.max(0, Math.round(h)); R.grids.push({ w, h, d: new Array(w * h).fill(0) }); return R.grids.length - 1; };
    B.ds_grid_destroy = id => { R.grids[Math.round(id)] = null; return 0; };
    B.ds_grid_exists = id => !!GR(id);
    B.ds_grid_width = id => (GR(id) ? GR(id).w : 0);
    B.ds_grid_height = id => (GR(id) ? GR(id).h : 0);
    B.ds_grid_resize = (id, w, h) => {
        const g = GR(id); if (!g) return 0; w = Math.round(w); h = Math.round(h);
        const d = new Array(w * h).fill(0);
        for (let y = 0; y < Math.min(h, g.h); y++) for (let x = 0; x < Math.min(w, g.w); x++) d[y * w + x] = g.d[y * g.w + x];
        g.w = w; g.h = h; g.d = d; return 0;
    };
    const inGrid = (g, x, y) => g && x >= 0 && y >= 0 && x < g.w && y < g.h;
    B.ds_grid_clear = (id, v) => { const g = GR(id); if (g) g.d.fill(v); return 0; };
    B.ds_grid_get = (id, x, y) => { const g = GR(id); x = Math.floor(x); y = Math.floor(y); return inGrid(g, x, y) ? g.d[y * g.w + x] : 0; };
    B.ds_grid_set = (id, x, y, v) => { const g = GR(id); x = Math.floor(x); y = Math.floor(y); if (inGrid(g, x, y)) g.d[y * g.w + x] = v; return 0; };
    B.ds_grid_add = (id, x, y, v) => { const g = GR(id); x = Math.floor(x); y = Math.floor(y); if (inGrid(g, x, y)) g.d[y * g.w + x] += v; return 0; };
    B.ds_grid_multiply = (id, x, y, v) => { const g = GR(id); x = Math.floor(x); y = Math.floor(y); if (inGrid(g, x, y)) g.d[y * g.w + x] *= v; return 0; };
    function gridRegion(id, x1, y1, x2, y2, fn) {
        const g = GR(id); if (!g) return;
        [x1, x2] = [Math.max(0, Math.min(x1, x2)), Math.min(g.w - 1, Math.max(x1, x2))];
        [y1, y2] = [Math.max(0, Math.min(y1, y2)), Math.min(g.h - 1, Math.max(y1, y2))];
        for (let y = Math.floor(y1); y <= y2; y++) for (let x = Math.floor(x1); x <= x2; x++) fn(g, y * g.w + x, x, y);
    }
    B.ds_grid_set_region = (id, x1, y1, x2, y2, v) => { gridRegion(id, x1, y1, x2, y2, (g, k) => { g.d[k] = v; }); return 0; };
    B.ds_grid_add_region = (id, x1, y1, x2, y2, v) => { gridRegion(id, x1, y1, x2, y2, (g, k) => { g.d[k] += v; }); return 0; };
    const regionVals = (id, x1, y1, x2, y2) => { const out = []; gridRegion(id, x1, y1, x2, y2, (g, k) => out.push(g.d[k])); return out; };
    B.ds_grid_get_max = (...a) => { const v = regionVals(...a); return v.length ? Math.max(...v) : 0; };
    B.ds_grid_get_min = (...a) => { const v = regionVals(...a); return v.length ? Math.min(...v) : 0; };
    B.ds_grid_get_sum = (...a) => regionVals(...a).reduce((s, v) => s + v, 0);
    B.ds_grid_get_mean = (...a) => { const v = regionVals(...a); return v.length ? v.reduce((s, x) => s + x, 0) / v.length : 0; };
    B.ds_grid_value_exists = (id, x1, y1, x2, y2, val) => regionVals(id, x1, y1, x2, y2).includes(val);
    B.ds_grid_copy = (dst, src) => { const s = GR(src); if (s) R.grids[Math.round(dst)] = { w: s.w, h: s.h, d: [...s.d] }; return 0; };

    // ------------------------------------------------------------------ ds_map / ds_stack / ds_queue / ds_priority
    R.maps = []; R.stacks = []; R.queues = []; R.prios = [];
    const MP = id => R.maps[Math.round(id)] || new Map();
    B.ds_map_create = () => { R.maps.push(new Map()); return R.maps.length - 1; };
    B.ds_map_destroy = id => { R.maps[Math.round(id)] = null; return 0; };
    B.ds_map_clear = id => { MP(id).clear(); return 0; };
    B.ds_map_size = id => MP(id).size;
    B.ds_map_empty = id => MP(id).size === 0;
    B.ds_map_add = (id, k, v) => { if (!MP(id).has(k)) MP(id).set(k, v); return 0; };
    B.ds_map_replace = (id, k, v) => { if (MP(id).has(k)) MP(id).set(k, v); return 0; };
    B.ds_map_delete = (id, k) => { MP(id).delete(k); return 0; };
    B.ds_map_exists = (id, k) => MP(id).has(k);
    B.ds_map_find_value = (id, k) => { const v = MP(id).get(k); return v === undefined ? 0 : v; };
    const mapKeys = id => [...MP(id).keys()].sort((a, b) => (typeof a === 'string' || typeof b === 'string') ? String(a).localeCompare(String(b)) : a - b);
    B.ds_map_find_first = id => { const k = mapKeys(id); return k.length ? k[0] : 0; };
    B.ds_map_find_last = id => { const k = mapKeys(id); return k.length ? k[k.length - 1] : 0; };
    B.ds_map_find_next = (id, key) => { const k = mapKeys(id), i = k.indexOf(key); return i >= 0 && i + 1 < k.length ? k[i + 1] : 0; };
    B.ds_map_find_previous = (id, key) => { const k = mapKeys(id), i = k.indexOf(key); return i > 0 ? k[i - 1] : 0; };
    B.ds_stack_create = () => { R.stacks.push([]); return R.stacks.length - 1; };
    B.ds_stack_destroy = id => { R.stacks[id] = null; return 0; };
    B.ds_stack_push = (id, ...v) => { R.stacks[id].push(...v); return 0; };
    B.ds_stack_pop = id => { const v = R.stacks[id].pop(); return v === undefined ? 0 : v; };
    B.ds_stack_top = id => { const s = R.stacks[id]; return s.length ? s[s.length - 1] : 0; };
    B.ds_stack_size = id => R.stacks[id].length; B.ds_stack_empty = id => R.stacks[id].length === 0;
    B.ds_stack_clear = id => { R.stacks[id].length = 0; return 0; };
    B.ds_queue_create = () => { R.queues.push([]); return R.queues.length - 1; };
    B.ds_queue_destroy = id => { R.queues[id] = null; return 0; };
    B.ds_queue_enqueue = (id, ...v) => { R.queues[id].push(...v); return 0; };
    B.ds_queue_dequeue = id => { const v = R.queues[id].shift(); return v === undefined ? 0 : v; };
    B.ds_queue_head = id => (R.queues[id].length ? R.queues[id][0] : 0);
    B.ds_queue_tail = id => { const q = R.queues[id]; return q.length ? q[q.length - 1] : 0; };
    B.ds_queue_size = id => R.queues[id].length; B.ds_queue_empty = id => R.queues[id].length === 0;
    B.ds_queue_clear = id => { R.queues[id].length = 0; return 0; };
    B.ds_priority_create = () => { R.prios.push([]); return R.prios.length - 1; };
    B.ds_priority_destroy = id => { R.prios[id] = null; return 0; };
    B.ds_priority_clear = id => { R.prios[id].length = 0; return 0; };
    B.ds_priority_size = id => R.prios[id].length; B.ds_priority_empty = id => R.prios[id].length === 0;
    B.ds_priority_add = (id, v, p) => { R.prios[id].push([v, p]); return 0; };
    B.ds_priority_change_priority = (id, v, p) => { const e = R.prios[id].find(e => e[0] === v); if (e) e[1] = p; return 0; };
    B.ds_priority_find_priority = (id, v) => { const e = R.prios[id].find(e => e[0] === v); return e ? e[1] : 0; };
    B.ds_priority_delete_value = (id, v) => { const q = R.prios[id], i = q.findIndex(e => e[0] === v); if (i >= 0) q.splice(i, 1); return 0; };
    const prioPick = (id, best, del) => {
        const q = R.prios[id]; if (!q.length) return 0;
        let k = 0; for (let i = 1; i < q.length; i++) if (best(q[i][1], q[k][1])) k = i;
        const v = q[k][0]; if (del) q.splice(k, 1); return v;
    };
    B.ds_priority_find_min = id => prioPick(id, (a, b) => a < b, false);
    B.ds_priority_find_max = id => prioPick(id, (a, b) => a > b, false);
    B.ds_priority_delete_min = id => prioPick(id, (a, b) => a < b, true);
    B.ds_priority_delete_max = id => prioPick(id, (a, b) => a > b, true);

    // ------------------------------------------------------------------ mp_grid (A* path finding on a cell grid)
    R.mpGrids = [];
    const MG = id => R.mpGrids[Math.round(id)];
    B.mp_grid_create = (left, top, hcells, vcells, cw, ch) => {
        hcells = Math.max(1, Math.round(hcells)); vcells = Math.max(1, Math.round(vcells));
        R.mpGrids.push({ left, top, w: hcells, h: vcells, cw, ch, cells: new Uint8Array(hcells * vcells) });
        return R.mpGrids.length - 1;
    };
    B.mp_grid_destroy = id => { R.mpGrids[Math.round(id)] = null; return 0; };
    B.mp_grid_clear_all = id => { const g = MG(id); if (g) g.cells.fill(0); return 0; };
    const mgSet = (g, cx, cy, v) => { cx = Math.floor(cx); cy = Math.floor(cy); if (g && cx >= 0 && cy >= 0 && cx < g.w && cy < g.h) g.cells[cy * g.w + cx] = v; };
    B.mp_grid_add_cell = (id, cx, cy) => { mgSet(MG(id), cx, cy, 1); return 0; };
    B.mp_grid_clear_cell = (id, cx, cy) => { mgSet(MG(id), cx, cy, 0); return 0; };
    function mgRect(id, x1, y1, x2, y2, v) {
        const g = MG(id); if (!g) return;
        if (x1 > x2) [x1, x2] = [x2, x1]; if (y1 > y2) [y1, y2] = [y2, y1];
        const c1 = Math.floor((x1 - g.left) / g.cw), c2 = Math.floor((x2 - g.left) / g.cw);
        const r1 = Math.floor((y1 - g.top) / g.ch), r2 = Math.floor((y2 - g.top) / g.ch);
        for (let cy = r1; cy <= r2; cy++) for (let cx = c1; cx <= c2; cx++) mgSet(g, cx, cy, v);
    }
    B.mp_grid_add_rectangle = (id, x1, y1, x2, y2) => { mgRect(id, x1, y1, x2, y2, 1); return 0; };
    B.mp_grid_clear_rectangle = (id, x1, y1, x2, y2) => { mgRect(id, x1, y1, x2, y2, 0); return 0; };
    B.mp_grid_add_instances = (id, obj, prec) => {
        const g = MG(id); if (!g) return 0;
        for (const i of resolve(obj, null, null)) {
            const b = i.__bbox(); if (!b) continue;
            // a cell is blocked when the instance's bounding box overlaps its interior
            const c1 = Math.floor((b.l - g.left) / g.cw), c2 = Math.ceil((b.r - g.left) / g.cw) - 1;
            const r1 = Math.floor((b.t - g.top) / g.ch), r2 = Math.ceil((b.b - g.top) / g.ch) - 1;
            for (let cy = r1; cy <= r2; cy++) for (let cx = c1; cx <= c2; cx++) mgSet(g, cx, cy, 1);
        }
        return 0;
    };
    B.mp_grid_get_cell = (id, cx, cy) => { const g = MG(id); cx = Math.floor(cx); cy = Math.floor(cy); return g && cx >= 0 && cy >= 0 && cx < g.w && cy < g.h ? (g.cells[cy * g.w + cx] ? -1 : 0) : -1; };
    B.mp_grid_path = (id, path, xs, ys, xg, yg, diag) => {
        const g = MG(id), p = R.paths[Math.round(path)]; if (!g || !p) return false;
        const cs = [Math.floor((xs - g.left) / g.cw), Math.floor((ys - g.top) / g.ch)];
        const cg = [Math.floor((xg - g.left) / g.cw), Math.floor((yg - g.top) / g.ch)];
        const ok = (x, y) => x >= 0 && y >= 0 && x < g.w && y < g.h && !g.cells[y * g.w + x];
        if (!ok(...cs) || !ok(...cg)) return false;
        const key = (x, y) => y * g.w + x, start = key(...cs), goal = key(...cg);
        const gs = new Map([[start, 0]]), came = new Map(), open = [[start, 0]], closed = new Set();
        const hfun = k => { const x = k % g.w, y = Math.floor(k / g.w); return Math.hypot(x - cg[0], y - cg[1]); };
        const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
        if (B.T(diag)) dirs.push([1, 1], [1, -1], [-1, 1], [-1, -1]);
        while (open.length) {
            let bi = 0; for (let i = 1; i < open.length; i++) if (open[i][1] < open[bi][1]) bi = i;
            const [cur] = open.splice(bi, 1)[0];
            if (cur === goal) break;
            if (closed.has(cur)) continue; closed.add(cur);
            const cx = cur % g.w, cy = Math.floor(cur / g.w);
            for (const [dx, dy] of dirs) {
                const nx = cx + dx, ny = cy + dy;
                if (!ok(nx, ny)) continue;
                if (dx && dy && (!ok(cx + dx, cy) || !ok(cx, cy + dy))) continue;   // no corner cutting
                const nk = key(nx, ny), ng = gs.get(cur) + (dx && dy ? Math.SQRT2 : 1);
                if (ng < (gs.has(nk) ? gs.get(nk) : Infinity)) { gs.set(nk, ng); came.set(nk, cur); open.push([nk, ng + hfun(nk)]); }
            }
        }
        if (!gs.has(goal)) return false;
        const cellsPath = []; for (let k = goal; k !== undefined; k = came.get(k)) { cellsPath.push(k); if (k === start) break; }
        cellsPath.reverse();
        p.points = cellsPath.map((k, i) => {
            if (i === 0) return { x: xs, y: ys, sp: 100 };
            if (i === cellsPath.length - 1) return { x: xg, y: yg, sp: 100 };
            return { x: g.left + (k % g.w + 0.5) * g.cw, y: g.top + (Math.floor(k / g.w) + 0.5) * g.ch, sp: 100 };
        });
        if (cellsPath.length === 1) p.points = [{ x: xs, y: ys, sp: 100 }, { x: xg, y: yg, sp: 100 }];
        p.closed = false;
        return true;
    };
    B.mp_grid_draw = id => {
        const g = MG(id); if (!g) return 0;
        withAlpha(ctx => {
            for (let y = 0; y < g.h; y++) for (let x = 0; x < g.w; x++) {
                ctx.fillStyle = g.cells[y * g.w + x] ? 'rgb(255,0,0)' : 'rgb(0,255,0)';
                ctx.fillRect(g.left + x * g.cw, g.top + y * g.ch, g.cw, g.ch);
            }
        });
        return 0;
    };

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
    B.path_assign = (target, src) => {
        const s = R.paths[Math.round(src)]; if (!s) return 0;
        R.paths[Math.round(target)] = { points: s.points.map(q => ({ ...q })), closed: s.closed }; return 0;
    };
    B.path_append = (target, src) => { const s = P(src); P(target).points.push(...s.points.map(q => ({ ...q }))); return 0; };
    B.path_reverse = id => { P(id).points.reverse(); return 0; };
    B.path_set_kind = (id, k) => 0;      // smooth paths are drawn as straight segments
    B.path_set_precision = (id, p) => 0;
    B.path_get_closed = id => P(id).closed;
    B.path_get_point_speed = (id, n) => (P(id).points[n] || { sp: 0 }).sp;
    B.path_change_point = (id, n, x, y, sp) => { const q = P(id).points[n]; if (q) Object.assign(q, { x, y, sp }); return 0; };
    B.path_delete_point = (id, n) => { P(id).points.splice(n, 1); return 0; };
    B.path_insert_point = (id, n, x, y, sp) => { P(id).points.splice(n, 0, { x, y, sp }); return 0; };
    B.path_shift = (id, dx, dy) => { for (const q of P(id).points) { q.x += dx; q.y += dy; } return 0; };
    // path motion for instances (path_start / path_end; advanced in the step loop)
    B.path_start = (self, path, speed, endaction, absolute) => {
        self.path_index = Math.round(path); self.path_position = 0; self.path_speed = speed;
        self.path_endaction = Math.round(endaction); self.__pathAbs = B.T(absolute);
        const p0 = pathAt(path, 0);
        self.__pathOx = self.__pathAbs ? 0 : self.x - p0.x; self.__pathOy = self.__pathAbs ? 0 : self.y - p0.y;
        if (self.__pathAbs) { self.x = p0.x; self.y = p0.y; }
        return 0;
    };
    B.path_end = self => { self.path_index = -1; return 0; };
    B._pathStep = function (i) {
        if (i.path_index < 0 || !R.paths[i.path_index]) return;
        const len = B.path_get_length(i.path_index);
        if (len <= 0) { i.path_index = -1; return; }
        const here = pathAt(i.path_index, i.path_position);
        i.path_position += i.path_speed * (here.sp / 100) / len;
        let ended = false;
        if (i.path_position >= 1 || i.path_position <= 0) {
            const act = i.path_endaction || 0;
            if (act === 1) i.path_position = i.path_position >= 1 ? i.path_position - 1 : i.path_position + 1;
            else if (act === 2) {
                const end = pathAt(i.path_index, 1), st = pathAt(i.path_index, 0);
                i.__pathOx += end.x - st.x; i.__pathOy += end.y - st.y; i.path_position -= Math.floor(i.path_position);
            } else if (act === 3) { i.path_speed = -i.path_speed; i.path_position = Math.max(0, Math.min(1, i.path_position)); }
            else { i.path_position = Math.max(0, Math.min(1, i.path_position)); ended = true; }
        }
        const q = pathAt(i.path_index, i.path_position);
        const nx = q.x + i.__pathOx, ny = q.y + i.__pathOy;
        if (nx !== i.x || ny !== i.y) i.__dir = B.point_direction(i.x, i.y, nx, ny);
        i.x = nx; i.y = ny;
        if (ended) { i.path_index = -1; runEvent(i, 'other_8', i); }
    };
    B.path_get_point_x = (id, n) => (P(id).points[n] || { x: 0 }).x;
    B.path_get_point_y = (id, n) => (P(id).points[n] || { y: 0 }).y;


    // ------------------------------------------------------------------ particle systems
    // Shapes are drawn procedurally (GameMaker's built-in particle textures are 64x64 images).
    R.psys = []; R.ptypes = [];
    Object.assign(B, {
        pt_shape_pixel: 0, pt_shape_disk: 1, pt_shape_square: 2, pt_shape_line: 3, pt_shape_star: 4,
        pt_shape_circle: 5, pt_shape_ring: 6, pt_shape_sphere: 7, pt_shape_flare: 8, pt_shape_spark: 9,
        pt_shape_explosion: 10, pt_shape_cloud: 11, pt_shape_smoke: 12, pt_shape_snow: 13,
        ps_shape_rectangle: 0, ps_shape_ellipse: 1, ps_shape_diamond: 2, ps_shape_line: 3,
        ps_distr_linear: 0, ps_distr_gaussian: 1, ps_distr_invgaussian: 2,
        ps_force_constant: 0, ps_force_linear: 1, ps_force_quadratic: 2, ps_change_all: 2, ps_change_shape: 1, ps_change_motion: 0,
    });
    const rnd = (a, b) => a + Math.random() * (b - a);
    const newType = () => ({
        shape: 0, sprite: -1, sizeMin: 1, sizeMax: 1, sizeIncr: 0, sizeWiggle: 0, xs: 1, ys: 1,
        oriMin: 0, oriMax: 0, oriIncr: 0, oriRel: false, colors: [16777215], colorMode: 'list', alphas: [1], additive: false,
        lifeMin: 100, lifeMax: 100, speedMin: 0, speedMax: 0, speedIncr: 0, dirMin: 0, dirMax: 0, dirIncr: 0,
        grav: 0, gravDir: 270, step: null, death: null,
    });
    B.part_type_create = () => { R.ptypes.push(newType()); return R.ptypes.length - 1; };
    const PT = id => R.ptypes[Math.round(id)];
    B.part_type_destroy = id => { R.ptypes[Math.round(id)] = null; return 0; };
    B.part_type_exists = id => !!PT(id);
    B.part_type_clear = id => { if (PT(id)) R.ptypes[Math.round(id)] = newType(); return 0; };
    B.part_type_shape = (id, s) => { const t = PT(id); if (t) { t.shape = s; t.sprite = -1; } return 0; };
    B.part_type_sprite = (id, spr, anim, stretch, random) => { const t = PT(id); if (t) t.sprite = spr; return 0; };
    B.part_type_size = (id, mn, mx, incr, wig) => { const t = PT(id); if (t) Object.assign(t, { sizeMin: mn, sizeMax: mx, sizeIncr: incr, sizeWiggle: wig }); return 0; };
    B.part_type_scale = (id, xs, ys) => { const t = PT(id); if (t) Object.assign(t, { xs, ys }); return 0; };
    B.part_type_orientation = (id, mn, mx, incr, wig, rel) => { const t = PT(id); if (t) Object.assign(t, { oriMin: mn, oriMax: mx, oriIncr: incr, oriRel: B.T(rel) }); return 0; };
    B.part_type_color1 = (id, c) => { const t = PT(id); if (t) { t.colors = [c]; t.colorMode = 'list'; } return 0; };
    B.part_type_color2 = (id, a, b) => { const t = PT(id); if (t) { t.colors = [a, b]; t.colorMode = 'list'; } return 0; };
    B.part_type_color3 = (id, a, b, c) => { const t = PT(id); if (t) { t.colors = [a, b, c]; t.colorMode = 'list'; } return 0; };
    B.part_type_color = B.part_type_color3;
    B.part_type_color_mix = (id, a, b) => { const t = PT(id); if (t) { t.colors = [a, b]; t.colorMode = 'mix'; } return 0; };
    B.part_type_color_rgb = (id, rmin, rmax, gmin, gmax, bmin, bmax) => { const t = PT(id); if (t) { t.colors = [rmin, rmax, gmin, gmax, bmin, bmax]; t.colorMode = 'rgb'; } return 0; };
    B.part_type_alpha1 = (id, a) => { const t = PT(id); if (t) t.alphas = [a]; return 0; };
    B.part_type_alpha2 = (id, a, b) => { const t = PT(id); if (t) t.alphas = [a, b]; return 0; };
    B.part_type_alpha3 = (id, a, b, c) => { const t = PT(id); if (t) t.alphas = [a, b, c]; return 0; };
    B.part_type_blend = (id, add) => { const t = PT(id); if (t) t.additive = B.T(add); return 0; };
    B.part_type_life = (id, mn, mx) => { const t = PT(id); if (t) Object.assign(t, { lifeMin: mn, lifeMax: mx }); return 0; };
    B.part_type_speed = (id, mn, mx, incr, wig) => { const t = PT(id); if (t) Object.assign(t, { speedMin: mn, speedMax: mx, speedIncr: incr }); return 0; };
    B.part_type_direction = (id, mn, mx, incr, wig) => { const t = PT(id); if (t) Object.assign(t, { dirMin: mn, dirMax: mx, dirIncr: incr }); return 0; };
    B.part_type_gravity = (id, amount, dir) => { const t = PT(id); if (t) Object.assign(t, { grav: amount, gravDir: dir }); return 0; };
    B.part_type_step = (id, n, child) => { const t = PT(id); if (t) t.step = [n, child]; return 0; };
    B.part_type_death = (id, n, child) => { const t = PT(id); if (t) t.death = [n, child]; return 0; };

    const newSystem = () => ({ parts: [], emitters: [], depth: 0, autoUpdate: true, autoDraw: true, ox: 0, oy: 0 });
    B.part_system_create = () => { R.psys.push(newSystem()); return R.psys.length - 1; };
    const PS = id => R.psys[Math.round(id)];
    B.part_system_destroy = id => { R.psys[Math.round(id)] = null; return 0; };
    B.part_system_exists = id => !!PS(id);
    B.part_system_clear = id => { const s = PS(id); if (s) { s.parts = []; s.emitters = []; } return 0; };
    B.part_system_depth = (id, d) => { const s = PS(id); if (s) s.depth = d; return 0; };
    B.part_system_position = (id, x, y) => { const s = PS(id); if (s) { s.ox = x; s.oy = y; } return 0; };
    B.part_system_automatic_update = (id, v) => { const s = PS(id); if (s) s.autoUpdate = B.T(v); return 0; };
    B.part_system_automatic_draw = (id, v) => { const s = PS(id); if (s) s.autoDraw = B.T(v); return 0; };
    B.part_particles_count = id => (PS(id) ? PS(id).parts.length : 0);
    B.part_particles_clear = id => { const s = PS(id); if (s) s.parts = []; return 0; };
    function spawn(s, x, y, typeId, n) {
        const t = PT(typeId); if (!s || !t) return;
        for (let k = 0; k < n; k++) {
            const life = Math.max(1, Math.round(rnd(t.lifeMin, t.lifeMax)));
            let col0 = t.colors[0];
            if (t.colorMode === 'mix') col0 = B.merge_color(t.colors[0], t.colors[1], Math.random());
            else if (t.colorMode === 'rgb') { const c = t.colors; col0 = B.make_color_rgb(rnd(c[0], c[1]), rnd(c[2], c[3]), rnd(c[4], c[5])); }
            s.parts.push({ t: typeId, x, y, age: 0, life, size: rnd(t.sizeMin, t.sizeMax), speed: rnd(t.speedMin, t.speedMax),
                dir: rnd(t.dirMin, t.dirMax), ori: rnd(t.oriMin, t.oriMax), col0, vx: 0, vy: 0 });
        }
    }
    B.part_particles_create = (id, x, y, type, n) => { spawn(PS(id), x, y, type, Math.round(n)); return 0; };
    B.part_particles_create_color = (id, x, y, type, col, n) => {
        const s = PS(id); const before = s ? s.parts.length : 0; spawn(s, x, y, type, Math.round(n));
        if (s) for (let k = before; k < s.parts.length; k++) s.parts[k].tint = col; return 0;
    };
    B.part_emitter_create = id => { const s = PS(id); if (!s) return -1; s.emitters.push({ x1: 0, x2: 0, y1: 0, y2: 0, shape: 0, distr: 0, type: -1, number: 0 }); return s.emitters.length - 1; };
    const EM = (id, e) => { const s = PS(id); return s && s.emitters[Math.round(e)]; };
    B.part_emitter_destroy = (id, e) => { const s = PS(id); if (s) s.emitters[Math.round(e)] = null; return 0; };
    B.part_emitter_destroy_all = id => { const s = PS(id); if (s) s.emitters = []; return 0; };
    B.part_emitter_exists = (id, e) => !!EM(id, e);
    B.part_emitter_clear = (id, e) => { const m = EM(id, e); if (m) Object.assign(m, { x1: 0, x2: 0, y1: 0, y2: 0, type: -1, number: 0 }); return 0; };
    B.part_emitter_region = (id, e, x1, x2, y1, y2, shape, distr) => { const m = EM(id, e); if (m) Object.assign(m, { x1, x2, y1, y2, shape, distr }); return 0; };
    function emitPoint(m) {
        const r = () => {
            if (m.distr === 1) { let v = 0; for (let k = 0; k < 3; k++) v += Math.random(); return v / 3; }
            if (m.distr === 2) { const v = Math.random(); return v < 0.5 ? v * v * 2 : 1 - (1 - v) * (1 - v) * 2; }
            return Math.random();
        };
        const cx = (m.x1 + m.x2) / 2, cy = (m.y1 + m.y2) / 2, hw = (m.x2 - m.x1) / 2, hh = (m.y2 - m.y1) / 2;
        if (m.shape === 3) { const t = r(); return [m.x1 + (m.x2 - m.x1) * t, m.y1 + (m.y2 - m.y1) * t]; }
        if (m.shape === 1) { const a = Math.random() * Math.PI * 2, d = Math.sqrt(r()); return [cx + Math.cos(a) * hw * d, cy + Math.sin(a) * hh * d]; }
        if (m.shape === 2) { for (; ;) { const x = r() * 2 - 1, y = r() * 2 - 1; if (Math.abs(x) + Math.abs(y) <= 1) return [cx + x * hw, cy + y * hh]; } }
        return [m.x1 + r() * (m.x2 - m.x1), m.y1 + r() * (m.y2 - m.y1)];
    }
    function burst(s, m, type, n) {
        if (n < 0) { if (Math.random() * -n >= 1) return; n = 1; }       // negative: one particle with chance 1/-n
        for (let k = 0; k < n; k++) { const [x, y] = emitPoint(m); spawn(s, x, y, type, 1); }
    }
    B.part_emitter_burst = (id, e, type, n) => { const s = PS(id), m = EM(id, e); if (s && m) burst(s, m, type, Math.round(n)); return 0; };
    B.part_emitter_stream = (id, e, type, n) => { const m = EM(id, e); if (m) Object.assign(m, { type, number: Math.round(n) }); return 0; };
    B.part_system_update = id => {
        const s = PS(id); if (!s) return 0;
        for (const m of s.emitters) if (m && m.type >= 0 && m.number) burst(s, m, m.type, m.number);
        const keep = [];
        for (const p of s.parts) {
            const t = PT(p.t); if (!t) continue;
            p.age++;
            if (p.age >= p.life) { if (t.death) spawn(s, p.x, p.y, t.death[1], t.death[0]); continue; }
            p.speed = Math.max(0, p.speed + t.speedIncr); p.dir += t.dirIncr; p.ori += t.oriIncr;
            p.size = Math.max(0, p.size + t.sizeIncr);
            if (t.grav) { const g = t.gravDir * Math.PI / 180; p.vx += Math.cos(g) * t.grav; p.vy -= Math.sin(g) * t.grav; }
            const d = p.dir * Math.PI / 180;
            p.x += Math.cos(d) * p.speed + p.vx; p.y += -Math.sin(d) * p.speed + p.vy;
            if (t.step && t.step[0]) spawn(s, p.x, p.y, t.step[1], t.step[0]);
            keep.push(p);
        }
        s.parts = keep;
        return 0;
    };
    const lerp3 = (vals, f, mix) => {
        if (vals.length === 1) return vals[0];
        if (vals.length === 2) return mix(vals[0], vals[1], f);
        return f < 0.5 ? mix(vals[0], vals[1], f * 2) : mix(vals[1], vals[2], (f - 0.5) * 2);
    };
    B.part_system_drawit = id => {
        const s = PS(id); if (!s || !s.parts.length) return 0;
        const ctx = R.ctx;
        for (const p of s.parts) {
            const t = PT(p.t); if (!t) continue;
            const f = p.age / p.life;
            const col = p.tint !== undefined ? p.tint : (t.colorMode === 'list' ? lerp3(t.colors, f, B.merge_color) : p.col0);
            const alpha = lerp3(t.alphas, f, (a, b, k) => a + (b - a) * k);
            ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
            ctx.globalCompositeOperation = t.additive ? 'lighter' : 'source-over';
            const x = p.x + s.ox, y = p.y + s.oy;
            if (t.sprite >= 0) { B.draw_sprite_ext(null, t.sprite, 0, x, y, p.size * t.xs, p.size * t.ys, p.ori, col, alpha); continue; }
            const w = 64 * p.size * t.xs, h = 64 * p.size * t.ys;
            ctx.fillStyle = css(col); ctx.strokeStyle = css(col);
            switch (t.shape) {
                case 0: ctx.fillRect(Math.round(x), Math.round(y), 1, 1); break;
                case 2: ctx.fillRect(x - w / 2, y - h / 2, w, h); break;
                case 3: ctx.lineWidth = Math.max(1, h / 8); ctx.beginPath(); ctx.moveTo(x - w / 2, y); ctx.lineTo(x + w / 2, y); ctx.stroke(); break;
                case 5: case 6: ctx.lineWidth = Math.max(1, w / (t.shape === 6 ? 6 : 16)); ctx.beginPath(); ctx.ellipse(x, y, w / 2.4, h / 2.4, 0, 0, Math.PI * 2); ctx.stroke(); break;
                case 4: {
                    ctx.beginPath();
                    for (let k = 0; k < 10; k++) { const a = -Math.PI / 2 + k * Math.PI / 5, rr = (k % 2 ? 0.2 : 0.5); ctx.lineTo(x + Math.cos(a) * w * rr, y + Math.sin(a) * h * rr); }
                    ctx.closePath(); ctx.fill(); break;
                }
                case 1: ctx.beginPath(); ctx.ellipse(x, y, w / 2.2, h / 2.2, 0, 0, Math.PI * 2); ctx.fill(); break;
                default: {                       // soft shapes: sphere, flare, spark, explosion, cloud, smoke, snow
                    const g = ctx.createRadialGradient(x, y, 0, x, y, Math.max(1, w / 2));
                    g.addColorStop(0, css(col, 1)); g.addColorStop(t.shape === 9 ? 0.15 : 0.5, css(col, 0.6)); g.addColorStop(1, css(col, 0));
                    ctx.fillStyle = g; ctx.fillRect(x - w / 2, y - h / 2, w, h);
                }
            }
        }
        ctx.globalAlpha = 1; ctx.globalCompositeOperation = 'source-over';
        return 0;
    };

    // ------------------------------------------------------------------ drag & drop action library
    // Each takes the acting instance first; actions that support "relative" get it as the last argument.
    const rx = (self, v, rel) => (rel ? self.x + v : v), ry = (self, v, rel) => (rel ? self.y + v : v);
    const cmp = (a, b, op) => (op === 1 ? a < b : op === 2 ? a > b : op === 3 ? a <= b : op === 4 ? a >= b : op === 5 ? a != b : a == b);
    Object.assign(B, {
        // move
        action_move: (self, dirs, speed, rel) => {
            const opts = []; const angles = [225, 270, 315, 180, -1, 0, 135, 90, 45];
            String(dirs).split('').forEach((c, k) => { if (c === '1') opts.push(angles[k]); });
            if (!opts.length) return 0;
            const a = opts[Math.floor(Math.random() * opts.length)];
            if (a < 0) { self.speed = 0; return 0; }
            self.speed = 0; self.direction = a; self.speed = rel ? self.speed + speed : speed; return 0;
        },
        action_set_motion: (self, dir, speed, rel) => { if (rel) B.motion_add(self, dir, speed); else B.motion_set(self, dir, speed); return 0; },
        action_move_point: (self, x, y, speed) => B.move_towards_point(self, x, y, speed),
        action_set_hspeed: (self, v, rel) => { self.hspeed = rel ? self.hspeed + v : v; return 0; },
        action_set_vspeed: (self, v, rel) => { self.vspeed = rel ? self.vspeed + v : v; return 0; },
        action_set_gravity: (self, dir, g, rel) => { self.gravity_direction = dir; self.gravity = rel ? self.gravity + g : g; return 0; },
        action_set_friction: (self, f, rel) => { self.friction = rel ? self.friction + f : f; return 0; },
        action_reverse_xdir: self => { self.hspeed = -self.hspeed; return 0; },
        action_reverse_ydir: self => { self.vspeed = -self.vspeed; return 0; },
        action_move_to: (self, x, y, rel) => { self.x = rx(self, x, rel); self.y = ry(self, y, rel); return 0; },
        action_move_start: self => { self.x = self.xstart; self.y = self.ystart; return 0; },
        action_move_random: (self, h, v) => B.move_random(self, h, v),
        action_snap: (self, h, v) => B.move_snap(self, h, v),
        action_wrap: (self, dir) => B.move_wrap(self, dir !== 1, dir >= 1, 0),
        action_move_contact: (self, dir, maxd, against) => (against ? B.move_contact_all : B.move_contact_solid)(self, dir, maxd),
        action_bounce: (self, precise, against) => (against ? B.move_bounce_all : B.move_bounce_solid)(self, precise),
        action_path: (self, path, speed, end, abs) => B.path_start(self, path, speed, end, abs),
        action_path_end: self => B.path_end(self),
        // instances
        action_create_object: (self, obj, x, y, rel) => { B.instance_create(rx(self, x, rel), ry(self, y, rel), obj); return 0; },
        action_create_object_motion: (self, obj, x, y, speed, dir, rel) => {
            const i = B.I(B.instance_create(rx(self, x, rel), ry(self, y, rel), obj)); B.motion_set(i, dir, speed); return 0;
        },
        action_create_object_random: (self, o1, o2, o3, o4, x, y, rel) => {
            const l = [o1, o2, o3, o4].filter(o => o >= 0); if (l.length) B.instance_create(rx(self, x, rel), ry(self, y, rel), l[Math.floor(Math.random() * l.length)]); return 0;
        },
        action_change_object: (self, obj, perf) => B.instance_change(self, obj, perf),
        action_kill_object: self => B.instance_destroy(self),
        action_kill_position: (self, x, y, rel) => {
            const px = rx(self, x, rel), py = ry(self, y, rel);
            for (const i of [...R.instances]) { const b = i.__bbox(); if (!i.__dead && b && px >= b.l && px < b.r && py >= b.t && py < b.b) B.instance_destroy(i); }
            return 0;
        },
        action_sprite_set: (self, spr, sub, speed) => { self.sprite_index = spr; if (sub >= 0) self.image_index = sub; self.image_speed = speed; return 0; },
        action_sprite_transform: (self, xs, ys, angle, mirror) => {
            self.image_xscale = xs * (mirror === 1 || mirror === 3 ? -1 : 1); self.image_yscale = ys * (mirror >= 2 ? -1 : 1); self.image_angle = angle; return 0;
        },
        action_sprite_color: (self, col, alpha) => { self.image_blend = col; self.image_alpha = alpha; return 0; },
        // sound
        action_sound: (self, snd, loop) => (B.T(loop) ? B.sound_loop(snd) : B.sound_play(snd)),
        action_end_sound: (self, snd) => B.sound_stop(snd),
        action_if_sound: (self, snd) => B.sound_isplaying(snd),
        // rooms & game
        action_previous_room: () => B.room_goto_previous(),
        action_next_room: () => B.room_goto_next(),
        action_current_room: () => B.room_restart(),
        action_another_room: (self, room) => B.room_goto(room),
        action_if_previous_room: () => B.room_previous(R.room) >= 0,
        action_if_next_room: () => B.room_next(R.room) >= 0,
        action_restart_game: () => B.game_restart(),
        action_end_game: () => B.game_end(),
        action_set_alarm: (self, steps, n, rel) => { self.alarm[n] = rel ? self.alarm[n] + steps : steps; return 0; },
        action_sleep: (self, ms, redraw) => { if (B.T(redraw)) B.screen_redraw(); return B.sleep(ms); },
        action_set_timeline: (self, tl, pos) => { self.timeline_index = tl; self.timeline_position = pos; return 0; },
        action_set_timeline_position: (self, pos, rel) => { self.timeline_position = rel ? self.timeline_position + pos : pos; return 0; },
        action_message: (self, msg) => B.show_message(msg),
        action_show_info: () => B.show_info(),
        action_execute_script: (self, scr, a0, a1, a2, a3, a4) => B.script_execute(self, self, scr, a0, a1, a2, a3, a4),
        action_inherited: self => B.event_inherited(self, self),
        action_set_cursor: (self, spr, show) => { B.cursor_sprite = spr; if (R.canvas) R.canvas.style.cursor = B.T(show) ? '' : 'none'; return 0; },
        // questions
        action_if_empty: (self, x, y, objs, rel) => (objs ? B.place_empty : B.place_free)(self, rx(self, x, rel), ry(self, y, rel)),
        action_if_collision: (self, x, y, objs, rel) => !(objs ? B.place_empty : B.place_free)(self, rx(self, x, rel), ry(self, y, rel)),
        action_if_object: (self, obj, x, y, rel) => B.place_meeting(self, rx(self, x, rel), ry(self, y, rel), obj),
        action_if_number: (self, obj, n, op) => cmp(B.instance_number(obj), n, op),
        action_if_dice: (self, sides) => Math.random() * sides < 1,
        action_if_question: (self, msg) => B.show_question(msg),
        action_if: (self, v) => v,
        action_if_mouse: (self, b) => B.mouse_check_button(b),
        action_if_aligned: (self, h, v) => (h <= 0 || Math.abs(self.x / h - Math.round(self.x / h)) < 1e-6) && (v <= 0 || Math.abs(self.y / v - Math.round(self.y / v)) < 1e-6),
        action_if_variable: (self, a, b, op) => cmp(a, b, op),
        // score, lives, health
        action_set_score: (self, v, rel) => { B.score = rel ? B.score + v : v; return 0; },
        action_if_score: (self, v, op) => cmp(B.score, v, op),
        action_set_lives: (self, v, rel) => { B.lives = rel ? B.lives + v : v; return 0; },
        action_if_lives: (self, v, op) => cmp(B.lives, v, op),
        action_set_health: (self, v, rel) => { B.health = rel ? B.health + v : v; return 0; },
        action_if_health: (self, v, op) => cmp(B.health, v, op),
        action_set_caption: (self, ss, sc, sl, lc, sh, hc) => {
            Object.assign(B, { show_score: !!ss, caption_score: sc, show_lives: !!sl, caption_lives: lc, show_health: !!sh, caption_health: hc }); return 0;
        },
        action_draw_score: (self, x, y, cap, rel) => B.draw_text(rx(self, x, rel), ry(self, y, rel), cap + B.string(B.score)),
        action_draw_lives: (self, x, y, cap, rel) => B.draw_text(rx(self, x, rel), ry(self, y, rel), cap + B.string(B.lives)),
        action_draw_life_images: (self, x, y, spr, rel) => {
            const w = B.sprite_get_width(spr); for (let k = 0; k < B.lives; k++) B.draw_sprite(self, spr, 0, rx(self, x, rel) + k * w, ry(self, y, rel)); return 0;
        },
        action_draw_health: (self, x1, y1, x2, y2, back, bar, rel) => {
            const cols = [0, 255, 65280, 16711680, 65535, 16711935, 16776960, 16777215];
            const b2 = [[255, 65280], [16777215, 0], [0, 0], [8421504, 8421504], [255, 255], [65280, 65280], [16711680, 16711680]][bar] || [255, 65280];
            return B.draw_healthbar(rx(self, x1, rel), ry(self, y1, rel), rx(self, x2, rel), ry(self, y2, rel), B.health, back < 0 ? 0 : cols[back] || 0, b2[0], b2[1], 0, back >= 0, true);
        },
        // drawing
        action_draw_sprite: (self, spr, x, y, sub, rel) => B.draw_sprite(self, spr, sub, rx(self, x, rel), ry(self, y, rel)),
        action_draw_background: (self, bg, x, y, tiled, rel) => B.draw_background(bg, rx(self, x, rel), ry(self, y, rel)),
        action_draw_text: (self, text, x, y, rel) => B.draw_text(rx(self, x, rel), ry(self, y, rel), text),
        action_draw_text_transformed: (self, text, x, y, xs, ys, ang, rel) => B.draw_text_transformed(rx(self, x, rel), ry(self, y, rel), text, xs, ys, ang),
        action_draw_variable: (self, v, x, y, rel) => B.draw_text(rx(self, x, rel), ry(self, y, rel), B.string(v)),
        action_draw_rectangle: (self, x1, y1, x2, y2, filled, rel) => B.draw_rectangle(rx(self, x1, rel), ry(self, y1, rel), rx(self, x2, rel), ry(self, y2, rel), filled === 1),
        action_draw_ellipse: (self, x1, y1, x2, y2, filled, rel) => B.draw_ellipse(rx(self, x1, rel), ry(self, y1, rel), rx(self, x2, rel), ry(self, y2, rel), filled === 1),
        action_draw_line: (self, x1, y1, x2, y2, rel) => B.draw_line(rx(self, x1, rel), ry(self, y1, rel), rx(self, x2, rel), ry(self, y2, rel)),
        action_color: (self, col) => B.draw_set_color(col),
        action_font: (self, font, align) => { B.draw_set_font(font); B.draw_set_halign(align); return 0; },
        action_fullscreen: () => 0,
    });

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
    const roomOrder = () => (typeof ROOM_ORDER !== 'undefined' && ROOM_ORDER.length ? ROOM_ORDER : ROOMS.map((r, i) => r ? i : -1).filter(i => i >= 0));
    B.room_next = r => { const o = roomOrder(), k = o.indexOf(r); return k >= 0 && k + 1 < o.length ? o[k + 1] : -1; };
    B.room_previous = r => { const o = roomOrder(), k = o.indexOf(r); return k > 0 ? o[k - 1] : -1; };
    B.room_goto_next = () => { const n = B.room_next(R.room); if (n >= 0) R.pendingRoom = n; return 0; };
    B.room_goto_previous = () => { const n = B.room_previous(R.room); if (n >= 0) R.pendingRoom = n; return 0; };
    Object.defineProperty(B, 'room_first', { get: () => roomOrder()[0] });
    Object.defineProperty(B, 'room_last', { get: () => roomOrder()[roomOrder().length - 1] });
    B.game_restart = () => { R.pendingRestart = true; return 0; };
    // sleep() freezes the game in GameMaker; here the frame loop pauses for that long
    B.sleep = ms => { R.sleepUntil = Math.max(R.sleepUntil || 0, performance.now() + Math.max(0, ms)); return 0; };
    B.screen_redraw = () => { const keep = R.ctx; draw(); R.ctx = keep; return 0; };
    B.screen_refresh = () => 0;
    B.io_handle = () => 0;
    B.window_set_caption = s => { B.room_caption = s; return 0; };
    B.window_get_caption = () => B.room_caption;
    B.cursor_sprite = -1;
    B.window_set_cursor = c => { if (R.canvas) R.canvas.style.cursor = c === -1 ? 'none' : ''; return 0; };
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
        if (!R.baseTitle) R.baseTitle = document.title;
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

    function restartGame() {
        for (const i of [...R.instances]) if (!i.__dead) runEvent(i, 'other_3', i);   // game end
        for (const i of R.instances) killInstance(i);
        compact();
        for (const k of Object.keys(G)) delete G[k];
        B.score = 0; lives = -1; health = 100;
        R.room = -1;
        gotoRoom(roomOrder()[0]);
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
    function toCanvas(img) {
        if (img instanceof HTMLCanvasElement) return img;
        const c = makeCanvas(img.width, img.height); c.getContext('2d').drawImage(img, 0, 0); return c;
    }
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
    B.sprite_replace_alpha = (ind, fname, imgnumb, precise, preload, xo, yo) =>
        B.sprite_replace(ind, fname, imgnumb, precise, 0, 0, preload, xo, yo);
    B.background_exists = b => !!R.backgrounds[Math.round(b)];
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
        const d = R.backgrounds[dst], s = R.backgrounds[src]; if (!d || !s || !d.image || !s.image) return 0;
        d.image = toCanvas(d.image); intensityAlpha(d.image, s.image); invalidateTint('bg' + dst); return 0;
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
        if (R.noMoreLives) { R.noMoreLives = false; forEachLive(i => runEvent(i, 'other_6', i)); }
        if (R.noMoreHealth) { R.noMoreHealth = false; forEachLive(i => runEvent(i, 'other_9', i)); }
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
            if (i.path_index >= 0) B._pathStep(i);
        });
        collisions();                                                              // collision events
        forEachLive(i => runEvent(i, 'step_2', i));                               // end step
        forEachLive(i => {                                                         // animation
            const n = i.image_number; if (!n) return;
            i.image_index += i.image_speed;
            if (i.image_index >= n) { i.image_index -= n; runEvent(i, 'other_7', i); }
            else if (i.image_index < 0) { i.image_index += n; runEvent(i, 'other_7', i); }
        });
        R.psys.forEach((ps, k) => { if (ps && ps.autoUpdate) B.part_system_update(k); });
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
        R.psys.forEach((ps, k) => { if (ps && ps.autoDraw) list.push({ __psys: k, depth: ps.depth, __order: -2 }); });
        list.sort((a, b) => (b.depth - a.depth) || (a.__order - b.__order));
        for (const i of list) {
            if (!(i instanceof Instance) && i.__psys !== undefined) { B.part_system_drawit(i.__psys); continue; }
            if (!(i instanceof Instance) && i.__tile) {
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
        if (B.cursor_sprite >= 0) B.draw_sprite(null, B.cursor_sprite, R.frameCount / 2, B.mouse_x, B.mouse_y);
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        let cap = B.room_caption;
        if (B.show_score) cap += ' ' + B.caption_score + B.score;
        if (B.show_lives) cap += ' ' + B.caption_lives + lives;
        if (B.show_health) cap += ' ' + B.caption_health + Math.round(health);
        if (!cap) cap = R.baseTitle;
        if (cap && document.title !== cap) document.title = cap;
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
        if (R.modal || R.messages.length) return;          // a dialog is open: the game is paused
        try {
            if (R.pendingRestart) { R.pendingRestart = false; restartGame(); }
            if (R.pendingRoom !== null) { const r = R.pendingRoom; R.pendingRoom = null; gotoRoom(r); }
            if (R.ended) return;
            step(); draw();
        } catch (e) {
            if (e instanceof ModalSuspend) { openModal(e, []); return; }
            reportError(e); throw e;
        }
        R.frameCount++;
    }

    function openModal(e, answers) {
        R.modal = { origin: e.origin, answers, req: e.req };
        R.pressed.clear(); R.released.clear(); R.mouse.pressed.clear(); R.mouse.released.clear();
        showDialog(e.req, value => {
            const m = R.modal; R.modal = null;
            R.mouse.buttons.clear(); R.keys.clear();
            if (!m.origin) return;
            R.replay = { answers: [...m.answers, value], idx: 0 };
            try { runEvent(m.origin.inst, m.origin.key, m.origin.other); }
            catch (err) {
                if (err instanceof ModalSuspend) { err.origin = err.origin || m.origin; openModal(err, R.replay.answers); }
                else { reportError(err); }
            } finally { R.replay = null; }
        });
    }

    // DOM dialogs drawn over the canvas
    function dialogLayer() {
        let el = document.getElementById('gm-dialog');
        if (!el) {
            el = document.createElement('div'); el.id = 'gm-dialog';
            el.style.cssText = 'position:absolute;inset:0;display:flex;align-items:center;justify-content:center;z-index:10;font:14px Arial,sans-serif;';
            (R.canvas.parentNode || document.body).appendChild(el);
        }
        el.innerHTML = ''; el.style.display = 'flex'; return el;
    }
    const BOX = 'background:#f0f0f0;color:#000;border:1px solid #888;box-shadow:0 4px 18px rgba(0,0,0,.5);border-radius:4px;';
    function showDialog(req, done) {
        const layer = dialogLayer();
        const finish = v => { layer.style.display = 'none'; layer.innerHTML = ''; window.removeEventListener('keydown', onKey, true); done(v); };
        let onKey = () => { };
        if (req.kind === 'menu') {
            // popup menu at the mouse position, like GameMaker's show_menu
            layer.style.alignItems = 'flex-start'; layer.style.justifyContent = 'flex-start';
            const back = document.createElement('div'); back.style.cssText = 'position:absolute;inset:0;';
            back.onmousedown = ev => { ev.preventDefault(); finish(req.def); };
            back.oncontextmenu = ev => ev.preventDefault();
            layer.appendChild(back);
            const menu = document.createElement('div');
            menu.style.cssText = BOX + 'position:absolute;padding:3px 0;min-width:120px;';
            const cr = R.canvas.getBoundingClientRect(), lr = layer.getBoundingClientRect();
            const vw = B.view_enabled ? B.view_wview[0] : R.canvas.width, vh = B.view_enabled ? B.view_hview[0] : R.canvas.height;
            menu.style.left = (cr.left - lr.left + R.mouse.x * cr.width / vw) + 'px';
            menu.style.top = (cr.top - lr.top + R.mouse.y * cr.height / vh) + 'px';
            let sel = 0; const rows = [];
            const paint = () => rows.forEach((row, k) => { row.style.background = k === sel ? '#3366cc' : ''; row.style.color = k === sel ? '#fff' : '#000'; });
            req.items.forEach((label, k) => {
                const row = document.createElement('div'); row.textContent = label;
                row.style.cssText = 'padding:4px 16px;cursor:pointer;white-space:nowrap;';
                row.onmouseenter = () => { sel = k; paint(); };
                row.onmouseup = ev => { ev.stopPropagation(); finish(k); };
                menu.appendChild(row); rows.push(row);
            });
            layer.appendChild(menu); paint();
            const mr = menu.getBoundingClientRect();
            if (mr.right > lr.right) menu.style.left = Math.max(0, parseFloat(menu.style.left) - (mr.right - lr.right)) + 'px';
            if (mr.bottom > lr.bottom) menu.style.top = Math.max(0, parseFloat(menu.style.top) - (mr.bottom - lr.bottom)) + 'px';
            onKey = ev => {
                ev.preventDefault(); ev.stopPropagation();
                if (ev.key === 'ArrowDown') { sel = (sel + 1) % rows.length; paint(); }
                else if (ev.key === 'ArrowUp') { sel = (sel - 1 + rows.length) % rows.length; paint(); }
                else if (ev.key === 'Enter' || ev.key === ' ') finish(sel);
                else if (ev.key === 'Escape') finish(req.def);
            };
        } else {
            layer.style.background = 'rgba(0,0,0,.25)';
            const box = document.createElement('div'); box.style.cssText = BOX + 'padding:16px 18px;max-width:70%;min-width:220px;';
            const text = document.createElement('div'); text.style.cssText = 'white-space:pre-wrap;margin-bottom:12px;';
            text.textContent = String(req.text).replace(/#/g, '\n'); box.appendChild(text);
            let input = null;
            if (req.kind === 'integer' || req.kind === 'string') {
                input = document.createElement('input'); input.value = String(req.def);
                input.style.cssText = 'width:100%;box-sizing:border-box;padding:4px;margin-bottom:12px;font:inherit;';
                box.appendChild(input);
            }
            const buttons = document.createElement('div'); buttons.style.cssText = 'text-align:right;';
            const button = (label, value) => {
                const b = document.createElement('button'); b.textContent = label;
                b.style.cssText = 'margin-left:8px;padding:4px 16px;font:inherit;cursor:pointer;';
                b.onclick = () => finish(typeof value === 'function' ? value() : value); buttons.appendChild(b); return b;
            };
            const value = () => req.kind === 'integer' ? (isNaN(parseFloat(input.value)) ? req.def : parseFloat(input.value)) : input ? input.value : 0;
            let first;
            if (req.kind === 'question') { first = button('Yes', true); button('No', false); }
            else { first = button('OK', value); if (input) button('Cancel', req.def); }
            box.appendChild(buttons); layer.appendChild(box);
            (input || first).focus(); if (input) input.select();
            onKey = ev => {
                if (ev.key === 'Enter') { ev.preventDefault(); finish(req.kind === 'question' ? true : value()); }
                else if (ev.key === 'Escape') { ev.preventDefault(); finish(req.kind === 'question' ? false : req.def); }
            };
        }
        window.addEventListener('keydown', onKey, true);
    }
    function nextMessage() {
        if (!R.messages.length) return;
        showDialog({ kind: 'message', text: R.messages[0] }, () => { R.messages.shift(); nextMessage(); });
    }
    B.show_message = s => { R.messages.push(B.string(s)); if (R.messages.length === 1) nextMessage(); return 0; };
    B.show_menu = (str, def) => ask({ kind: 'menu', items: B.string(str).split('|'), def });
    B.show_menu_pos = (x, y, str, def) => ask({ kind: 'menu', items: B.string(str).split('|'), def });
    B.get_integer = (str, def) => ask({ kind: 'integer', text: str, def });
    B.get_string = (str, def) => ask({ kind: 'string', text: str, def });
    B.show_question = str => ask({ kind: 'question', text: str });

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
            if (R.modal || R.messages.length) return;     // keys go to the open dialog
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

        gotoRoom(roomOrder()[0]);
        // fixed-rate loop at room_speed
        let last = performance.now(), acc = 0;
        R.fpsTime = last; let frames = 0;
        const loop = now => {
            if (R.ended) return;
            const dt = Math.min(250, now - last); last = now; acc += dt;
            const stepMs = 1000 / B.room_speed;
            let n = 0;
            if (R.sleepUntil && now < R.sleepUntil) { acc = 0; requestAnimationFrame(loop); return; }
            while (acc >= stepMs && n < 4) { frame(); acc -= stepMs; n++; frames++; if (R.sleepUntil > performance.now()) break; }
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
