/datum/component/force_armor
	var/magic = FALSE
	var/holy = FALSE

/datum/component/force_armor/Initialize(_magic = FALSE, _holy = FALSE)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/can_protect)
	else
		return COMPONENT_INCOMPATIBLE

	magic = _magic
	holy = _holy

/datum/component/force_armor/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/can_protect, TRUE)

/datum/component/force_armor/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/force_armor/proc/can_protect(datum/source, _magic, _holy, list/protection_sources)
	if((_magic && magic) || (_holy && holy))
		protection_sources += parent
		return COMPONENT_BLOCK_MAGIC