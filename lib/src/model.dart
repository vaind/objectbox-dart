import "dart:ffi";

import "bindings/bindings.dart";
import "bindings/helpers.dart";
import "ffi/cstring.dart";

class Entity {
    final int id, uid;
    const Entity({this.id, this.uid}) : assert(id != null && id != 0), assert(uid != null && uid != 0);
}

class Property {
    final int type;
    final int id, uid;
    const Property({this.id, this.uid, this.type = null});
}

class Id {
    final int id, uid;
    const Id({this.id, this.uid});      // type is always long
}

class Model {
    Pointer<Void> _objectboxModel;

    Model(List<Map<String, dynamic>> modelDefinitions) {
        _objectboxModel = bindings.obx_model();
        checkObxPtr(_objectboxModel, "failed to create model");

        try {
            // transform classes into model descriptions and loop through them
            modelDefinitions.forEach((m) {
                // start entity
                var entityName = CString(m["entity"]["name"]);
                checkObx(bindings.obx_model_entity(_objectboxModel, entityName.ptr, m["entity"]["id"], m["entity"]["uid"]));
                entityName.free();

                // add all properties
                m["properties"].forEach((p) {
                    var propertyName = CString(p["name"]);
                    checkObx(bindings.obx_model_property(_objectboxModel, propertyName.ptr, p["type"], p["id"], p["uid"]));
                    checkObx(bindings.obx_model_property_flags(_objectboxModel, p["flags"]));
                    propertyName.free();
                });

                // set last property id
                if(m["properties"].length > 0) {
                    var lastProp = m["properties"][m["properties"].length - 1];
                    checkObx(bindings.obx_model_entity_last_property_id(_objectboxModel, lastProp["id"], lastProp["uid"]));
                }
            });

            // set last entity id
            if(modelDefinitions.length > 0) {
                var lastEntity = modelDefinitions[modelDefinitions.length - 1]["entity"];
                bindings.obx_model_last_entity_id(_objectboxModel, lastEntity["id"], lastEntity["uid"]);
            }
        } catch(e) {
            bindings.obx_model_free(_objectboxModel);
            _objectboxModel = null;
            rethrow;
        }
    }

    get ptr => _objectboxModel;
}
