"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IsPremium = exports.IS_PREMIUM_KEY = void 0;
const common_1 = require("@nestjs/common");
exports.IS_PREMIUM_KEY = 'isPremiumRequired';
const IsPremium = () => (0, common_1.SetMetadata)(exports.IS_PREMIUM_KEY, true);
exports.IsPremium = IsPremium;
//# sourceMappingURL=is-premium.decorator.js.map