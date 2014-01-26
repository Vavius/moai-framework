--------------------------------------------------------------------------------
-- Extensions for default MOAI objects
-- 
-- 
-- 
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Common overrides for all prop subclasses
--------------------------------------------------------------------------------

local function initPropInterface ( interface, superInterface )

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    function interface.setParent ( self, parent )

        self.parent = parent

        superInterface.clearAttrLink ( self, MOAIColor.INHERIT_COLOR )
        superInterface.clearAttrLink ( self, MOAITransform.INHERIT_TRANSFORM )
        superInterface.clearAttrLink ( self, MOAIProp.INHERIT_VISIBLE )

        if parent then
            superInterface.setAttrLink ( self, MOAIColor.INHERIT_COLOR, parent, MOAIColor.COLOR_TRAIT )
            superInterface.setAttrLink ( self, MOAIProp.INHERIT_VISIBLE, parent, MOAIProp.ATTR_VISIBLE )
            superInterface.setAttrLink ( self, MOAITransform.INHERIT_TRANSFORM, parent, MOAITransform.TRANSFORM_TRAIT )
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    function interface.getVisible ( self )
        return superInterface.getAttr ( self, MOAIProp.ATTR_VISIBLE ) > 0
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    function interface.setScissorRect ( self, scissorRect )
        self.scissorRect = scissorRect
        superInterface.setScissorRect ( self, scissorRect )
    end
end


--------------------------------------------------------------------------------
-- MOAIProp
--------------------------------------------------------------------------------

MOAIProp.extend (

    'MOAIProp',
    
    --------------------------------------------------------------------------------
    function ( interface, class, superInterface, superClass )
        initPropInterface ( interface, superInterface )
        
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        function interface.setLayer ( self, layer )

            if self.layer == layer then
                return
            end

            if self.layer then
                self.layer:removeProp ( self )
            end

            self.layer = layer

            if self.layer then
                layer:insertProp ( self )
            end
        end

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- function interface.setTexture ( self, texture )

        -- end

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        function interface.setIndexByName ( self, name )

            if type(name) == "string" then
                local index = (self.deck and self.deck.names) and self.deck.names[name] or superInterface.getIndex(self)
                self:setIndex(index)
            end
        end

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        function interface.setFlip ( self, x, y )
            
        end
    end
)

--------------------------------------------------------------------------------
-- MOAILayer
--------------------------------------------------------------------------------

MOAILayer.extend (

    'MOAILayer',
    
    --------------------------------------------------------------------------------
    function ( interface, class, superInterface, superClass )
        initPropInterface ( interface, superInterface )
        
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        function interface.setLayer ( self, layer )
            -- nested layers not supported
        end
    end
)



--------------------------------------------------------------------------------
-- MOAITextBox
--------------------------------------------------------------------------------

MOAITextBox.extend (

    'MOAITextBox', 

    --------------------------------------------------------------------------------
    function ( interface, class, superInterface, superClass )
        initPropInterface ( interface, superInterface )
        
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        function interface.setLayer ( self, layer )

            if self.layer == layer then
                return
            end

            if self.layer then
                self.layer:removeProp ( self )
            end

            self.layer = layer

            if self.layer then
                layer:insertProp ( self )
            end
        end
    end

)



