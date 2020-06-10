note
	description: "Event channel that implements a publish-subscribe mechanism"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_EVENT_CHANNEL [EVENT_DATA -> TUPLE create default_create end]

inherit

	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialize list.
		do
			create subscriptions_impl.make_equal
			create once_subscriptions_impl.make_equal
		end

feature -- Access

	subscriptions: DS_LINEAR [PROCEDURE [ANY, EVENT_DATA]]
			-- List of subscriptions
		do
			Result := subscriptions_impl
		ensure
			result_exist: Result /= Void
		end

	once_subscriptions: DS_LINEAR [PROCEDURE [ANY, EVENT_DATA]]
			-- List of once subscriptions
		do
			Result := once_subscriptions_impl
		ensure
			result_exist: Result /= Void
		end

feature -- Element change

	subscribe (an_action: PROCEDURE [ANY, EVENT_DATA])
			-- Add `an_action' to the subscription list.
		require
			an_action_not_void: an_action /= Void
			an_action_not_already_subscribed: not has (an_action)
		do
			subscriptions_impl.put_last (an_action)
		ensure
			an_action_subscribed: has (an_action)
			count_incremented: subscriptions.count = old subscriptions.count + 1
		end

	subscribe_kamikaze (an_action: PROCEDURE [ANY, EVENT_DATA])
			-- Add `an_action' to the once subscription list.
			-- `an_action' will be called next time the event occurs and will be removed afterwards.
		require
			an_action_not_void: an_action /= Void
			an_action_not_already_subscribed: not has_once (an_action)
		do
			once_subscriptions_impl.put_last (an_action)
		ensure
			an_action_subscribed: has_once (an_action)
			count_incremented: once_subscriptions.count = old once_subscriptions.count + 1
		end

	unsubscribe (an_action: PROCEDURE [ANY, EVENT_DATA])
			-- Remove `an_action' from the subscription list.
		require
			an_action_not_void: an_action /= Void
		do
			subscriptions_impl.delete (an_action)
		ensure
			an_action_unsubscribed: not has (an_action)
			count_decremenetd: old has (an_action) implies subscriptions.count = old subscriptions.count - 1
		end

	unsubscribe_kamikaze (an_action: PROCEDURE [ANY, EVENT_DATA])
			-- Remove `an_action' from the once subscription list.
		require
			an_action_not_void: an_action /= Void
		do
			once_subscriptions_impl.delete (an_action)
		ensure
			an_action_unsubscribed: not has_once (an_action)
			count_decremenetd: old has_once (an_action) implies once_subscriptions.count = old once_subscriptions.count - 1
		end

feature -- Publication

	publish (arguments: EVENT_DATA)
			-- Publish all not suspended actions from the subscription list.
		require
			arguments_not_void: arguments /= Void
		local
			cursor: DS_LINKED_LIST_CURSOR [PROCEDURE [ANY, EVENT_DATA]]
		do
			if not is_suspended then
				if not subscriptions_impl.is_empty then
					from
						cursor := subscriptions_impl.new_cursor
						cursor.start
					until
						cursor.after
					loop
						cursor.item.call (arguments)
						if not cursor.after then
							cursor.forth
						end
					end
				end

				if not once_subscriptions_impl.is_empty then
					from
						cursor := once_subscriptions_impl.new_cursor
						cursor.start
					until
						cursor.after
					loop
						cursor.item.call (arguments)
						if not cursor.after then
							cursor.remove
						end
					end
				end
			end
		end

feature -- Status report

	is_suspended: BOOLEAN
			-- Is the publication of all actions from the subscription list suspended?
			-- (Answer: no by default.)

	has (an_action: PROCEDURE [ANY, EVENT_DATA]): BOOLEAN
			-- Is `an_action' subscribed?
		do
			Result := subscriptions_impl.has (an_action)
		end

	has_once (an_action: PROCEDURE [ANY, EVENT_DATA]): BOOLEAN
			-- Is `an_action' subscribed in the once list?
		require
			an_action_not_void: an_action /= Void
		do
			Result := once_subscriptions_impl.has (an_action)
		end

feature -- Status settings

	suspend_subscription
			-- Ignore the call of all actions from the subscription list,
			-- until feature restore_subscription is called.
		do
			is_suspended := True
		ensure
			subscription_suspended: is_suspended
		end

	restore_subscription 
			-- Consider again the call of all actions from the subscription list,
			-- until feature suspend_subscription is called.
		do
			is_suspended := False
		ensure
			subscription_not_suspended: not is_suspended
		end

feature {NONE} -- Implementation

	subscriptions_impl: DS_LINKED_LIST [PROCEDURE [ANY, EVENT_DATA]]
			-- List of subscriptions

	once_subscriptions_impl: DS_LINKED_LIST [PROCEDURE [ANY, EVENT_DATA]]
			-- List of once subscriptions

end
