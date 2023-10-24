local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__Iterator = ____lualib.__TS__Iterator
local ____exports = {}
local ____js = require("js")
local js_new = ____js.js_new
local global = ____js.global
local ____MessageHandlers = require("engine.MessageHandlers")
local HandlerTypes = ____MessageHandlers.HandlerTypes
function ____exports.MakeListenerDict(self)
    local dict = {}
    for ____, key in ipairs(HandlerTypes) do
        dict[key] = {}
    end
    return dict
end
____exports.MessageDispatcher = __TS__Class()
local MessageDispatcher = ____exports.MessageDispatcher
MessageDispatcher.name = "MessageDispatcher"
function MessageDispatcher.prototype.____constructor(self, scene)
    self.listeners = ____exports.MakeListenerDict(nil)
    self.functionQueue = {}
    self.onCollision = (function()
        local dummyVector3 = js_new(global.THREE.Vector3)
        return function(____, a, b, contactPointOnA, contactPointOnB, contactDeltaV)
            for ____, listener in ipairs(__TS__ArraySlice(self.listeners.collision)) do
                if a ~= nil and listener.body.body.id == a.id then
                    local ____temp_0
                    if b == nil then
                        ____temp_0 = nil
                    else
                        ____temp_0 = self.scene:getBodyById(b.id)
                    end
                    local bBody = ____temp_0
                    listener:onCollision(
                        bBody,
                        contactPointOnA,
                        dummyVector3:copy(contactDeltaV):multiplyScalar(-1)
                    )
                elseif b ~= nil and listener.body.body.id == b.id then
                    local ____temp_1
                    if a == nil then
                        ____temp_1 = nil
                    else
                        ____temp_1 = self.scene:getBodyById(a.id)
                    end
                    local aBody = ____temp_1
                    listener:onCollision(
                        aBody,
                        contactPointOnB,
                        dummyVector3:copy(contactDeltaV)
                    )
                end
            end
        end
    end)(nil)
    self.scene = scene
end
function MessageDispatcher.prototype.clearListeners(self)
    self.listeners = ____exports.MakeListenerDict(nil)
    self.functionQueue = {}
end
function MessageDispatcher.prototype.removeAllListenersFromBody(self, body)
    for ____, elem in ipairs(body.elements) do
        self:removeAllListenersFromElement(elem)
    end
end
function MessageDispatcher.prototype.removeAllListenersFromElement(self, elem)
    for key in pairs(self.listeners) do
        local listeners = self.listeners[key]
        do
            local i = 0
            while i < #listeners do
                if listeners[i + 1] == elem then
                    __TS__ArraySplice(listeners, i, 1)
                    i = i - 1
                end
                i = i + 1
            end
        end
    end
    do
        local i = 0
        while i < #self.functionQueue do
            if self.functionQueue[i + 1].element == elem then
                __TS__ArraySplice(self.functionQueue, i, 1)
                i = i - 1
            end
            i = i + 1
        end
    end
end
function MessageDispatcher.prototype.removeListener(self, ____type, listener)
    local listeners = self.listeners[____type]
    local index = __TS__ArrayIndexOf(listeners, listener)
    if index >= 0 then
        __TS__ArraySplice(listeners, index, 1)
    end
end
function MessageDispatcher.prototype.addListener(self, ____type, listener)
    local ____self_listeners_____type_2 = self.listeners[____type]
    ____self_listeners_____type_2[#____self_listeners_____type_2 + 1] = listener
end
function MessageDispatcher.prototype.hasListenerOfType(self, ____type, subtype)
    if self.listeners[____type] == nil then
        return false
    end
    if subtype ~= nil then
        for ____, listener in __TS__Iterator(self.listeners[____type]) do
            if listener.hasSubtype ~= nil and listener:hasSubtype(subtype) then
                return true
            end
        end
        return false
    else
        return #self.listeners[____type] > 0
    end
end
function MessageDispatcher.prototype.queueDelayedFunction(self, element, func, delay, ...)
    local args = {...}
    local fq = {element = element, func = func, delay = delay, args = args}
    local ____self_functionQueue_3 = self.functionQueue
    ____self_functionQueue_3[#____self_functionQueue_3 + 1] = fq
    return fq
end
function MessageDispatcher.prototype.removeQueuedFunction(self, fq)
    local index = __TS__ArrayIndexOf(self.functionQueue, fq)
    if index >= 0 then
        __TS__ArraySplice(self.functionQueue, index, 1)
    end
end
function MessageDispatcher.prototype.updateFunctionQueue(self, dt)
    local funcsToCall = {}
    do
        local i = 0
        while i < #self.functionQueue do
            local fq = self.functionQueue[i + 1]
            fq.delay = fq.delay - dt
            if fq.delay <= 0 then
                funcsToCall[#funcsToCall + 1] = fq
                __TS__ArraySplice(self.functionQueue, i, 1)
                i = i - 1
            end
            i = i + 1
        end
    end
    for ____, fq in ipairs(funcsToCall) do
        fq:func(table.unpack(fq.args))
    end
end
function MessageDispatcher.prototype.onUpdate(self)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.update)) do
        listener:onUpdate()
    end
end
function MessageDispatcher.prototype.onButtonPress(self, button)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.button)) do
        listener:onButtonPress(button)
    end
end
function MessageDispatcher.prototype.onButtonHold(self, button)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.button)) do
        listener:onButtonHold(button)
    end
end
function MessageDispatcher.prototype.onButtonRelease(self, button)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.button)) do
        listener:onButtonRelease(button)
    end
end
function MessageDispatcher.prototype.onDrag(self, dx, dy)
    for ____, listener in ipairs(self.listeners.drag) do
        listener:onDrag(dx, dy)
    end
end
function MessageDispatcher.prototype.onTap(self)
    local didInteract = false
    if self.scene.memory.player then
        didInteract = self:onInteract(self.scene.memory.player)
    end
    if not didInteract then
        for ____, listener in ipairs(__TS__ArraySlice(self.listeners.tap)) do
            listener:onTap()
        end
    end
end
function MessageDispatcher.prototype.onSwipe(self, dx, dy)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.swipe)) do
        listener:onSwipe(dx, dy)
    end
end
function MessageDispatcher.prototype.onHoldStart(self)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.hold)) do
        listener:onHoldStart()
    end
end
function MessageDispatcher.prototype.onHoldRelease(self)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.hold)) do
        listener:onHoldRelease()
    end
end
function MessageDispatcher.prototype.onAimStart(self)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.aim)) do
        listener:onAimStart()
    end
end
function MessageDispatcher.prototype.onAim(self, dx, dy)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.aim)) do
        listener:onAim(dx, dy)
    end
end
function MessageDispatcher.prototype.onAimRelease(self, dx, dy)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.aim)) do
        listener:onAimRelease(dx, dy)
    end
end
function MessageDispatcher.prototype.onInteract(self, interactor)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.interact)) do
        if listener:isInInteractionRange(interactor) then
            local didInteract = listener:onInteract(interactor)
            if didInteract then
                return didInteract
            end
        end
    end
    return false
end
function MessageDispatcher.prototype.onActorDestroyed(self, actor)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.actorDestroyed)) do
        listener:onActorDestroyed(actor)
    end
end
function MessageDispatcher.prototype.onHitPointChange(self, source, previousHP, currentHP)
    for ____, listener in ipairs(__TS__ArraySlice(self.listeners.hitPointsChanged)) do
        listener:onHitPointChange(source, previousHP, currentHP)
    end
end
return ____exports
